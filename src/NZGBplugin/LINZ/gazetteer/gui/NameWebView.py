################################################################################
#
#  New Zealand Geographic Board gazetteer application,
#  Crown copyright (c) 2020, Land Information New Zealand on behalf of
#  the New Zealand Government.
#
#  This file is released under the MIT licence. See the LICENCE file found
#  in the top-level directory of this distribution for more information.
#
################################################################################

from __future__ import with_statement

import sys
import os.path
import datetime
import re
try:
    import json
except ImportError:
    import simplejson as json

from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtWebKit import *

import DatabaseConfiguration

from LINZ.gazetteer import Model
from LINZ.gazetteer import Database
from LINZ.Util import pyratemp, dms

class NameWebView( QWebView ):

    Debug = False
    _months=('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')

    @staticmethod
    def _strftime( date ):
        '''
        Date formatting function as strftime doesn't handle year < 1900
        '''
        mon=NameWebView._months[date.month-1]
        return "{0:02d}-{1}-{2:04d}".format(date.day,mon,date.year)

    ''' 
    Custom signals emitted by the NameWebView 
    '''
    nameChanged = pyqtSignal(int,str,name="nameChanged")
    '''
    JSON handler to serialize dates into JSON in a well defined format
    '''
    @staticmethod
    def jsonHandler(obj):
        if type(obj) in (datetime.date, datetime.datetime):
            return NameWebView._strftime(obj)
 
    class Association( object ):

        def __init__( self, text, name, association ):
            self.text = text
            self.name = name
            self.association = association

    class Template( QObject ):
        '''
        Template class is used to build pages from templates using the 
        pyratemp modul.  Handles loading templates files, expanding the
        template to generate the page HTML, and provides some functions 
        used by the templates.
        '''

        def __init__( self, name, basedir=None ):
            if not basedir:
                basedir=os.path.join(os.path.dirname(__file__),'html')
            self._file=os.path.join(basedir,name+'.template.html')
            self._stat = None
            self._template = None
            self._editdata = {}

        def _load( self ):
            if self._template==None or self._stat != os.path.getmtime(self._file):
                try:
                    if not os.path.exists( self._file ):
                        raise ValueError('Template file '+self._file+' does not exist')
                    self._stat = os.path.getmtime(self._file)
                    self._template = pyratemp.Template(filename=self._file)
                except:
                    msg = unicode(sys.exc_info()[1])
                    def tfun( **kwords ):
                        return ("<html><head><title>Error</title></head><body><h1>Error</h1><p>"+
                                pyratemp.escape(msg,pyratemp.HTML)+
                                "</p></body></html>")
                    self._template=tfun

        @staticmethod
        def escape( text ):
            '''
            Add HTML escapes to text
            '''
            return pyratemp.escape(text,pyratemp.HTML)

        @staticmethod
        def selectOptions( mlist ):
            '''
            Generates a set of <option> entries for a given
            a list of (value,text) tuples. Assumes that the 
            values do not need to be escaped.
            '''
            return ''.join(
                ['<option value="'+x[0]+'">'+NameWebView.Template.escape(x[1])+'</option>' 
                 for x in mlist
                ])

        def htmlText( self, text ):
            '''
            Add HTML escapes to text,and replaces new lines with
            line breaks
            '''
            text = self.escape(text or '')
            text = text.replace("\n","<br />")
            return text

        def lookupOptions( self, code_group, showDescriptions=False ):
            '''
            Forms an option list from a code matching a SystemCode
            code_group can be selected
            '''
            vfunc = lambda x: x.value+(
                ' ('+x.description+')' if showDescriptions and x.description
                else '')
            mapping = Model.SystemCode.codeGroup(code_group)
            mlist = [(c.code,vfunc(c)) for c in mapping]
            mlist.sort( key=lambda x:x[1] )
            return self.selectOptions( mlist )

        def dateFormat( self, dt ):
            '''
            Converts a date time to a dd-MMM-yyyy format
            '''
            if type(dt) in (datetime.date, datetime.datetime):
                return NameWebView._strftime(dt)
            else:
                return str(dt)

        def getCoordinates( self, feature ):
            coords = []
            try:
                latlon = feature.location()
                coords.append(('Longitude/latitude',
                               dms.deg_dms(latlon[0],1,'WE')+' '+
                               dms.deg_dms(latlon[1],1,'SN')+' ('+
                               "{0:.6f} {1:.6f}".format(*latlon)+')'
                              ))
                if latlon[0] > 165.0 and latlon[0] < 180.0 and latlon[1] > -48 and latlon[1] < -34:
                    nztm = feature.location(2193)
                    coords.append(('NZTM',"{0:.1f} {1:.1f}".format(*nztm)))
            except:
                pass
            return coords

        def id( self, item, attr=None ):
            '''
            Returns the id of an item, and optionally an attribute of
            an item.  This is used the Model module to uniquely 
            identify the entity.

            Attribute values are saved in the _editdata dictionary so that
            when the template is complete the set of data referenced
            in the template can supplied to the page.
            '''
            if attr:
                id, value = Model.objectAttrId( item, attr )
                self._editdata[id] = value
                # print id, unicode(value).encode('utf8')
                return id
            return Model.objectId(item)

        def editdata( self ):
            '''
            The dictionary of edit values loaded into the template
            '''
            return self._editdata

        def sortEvents( self, events ):
            '''
            Used to define the order of displaying events
            '''
            return sorted(events,key=lambda x:x.event_date,reverse=True)

        def sortAnnotations( self, code, annotations ):
            '''
            Used to define the order of displaying annotations.  Based on the 
            order defined in the APSD code NAOR (name annotations) or FAOR
            (feature annotations), then 
            '''

            order = Model.SystemCode.lookup('APSD',code) or '';
            lookup={}
            for i, atype in enumerate(order.split()):
                lookup[atype]="%04d" % (i,)
            return sorted(annotations, key=lambda x: lookup.get(x.annotation_type,'9999')+x.annotation_type)

        def sortNameAnnotations( self, annotations ):
            return self.sortAnnotations( 'NAOR', annotations )

        def sortFeatureAnnotations( self, annotations ):
            return self.sortAnnotations( 'FAOR', annotations )

        def expand( self, tempvars ):
            self._load()
            self._editdata={}
            tdict= {
                'lookup': Model.SystemCode.lookup,
                'lookupCategory': Model.SystemCode.lookupCategory,
                'getCoordinates': self.getCoordinates,
                'htmlText': self.htmlText,
                'dateFormat': self.dateFormat,
                'lookupOptions': self.lookupOptions,
                'id': self.id,
                'sortEvents': self.sortEvents,
                'sortNameAnnotations': self.sortNameAnnotations,
                'sortFeatureAnnotations': self.sortFeatureAnnotations,
                }
            tdict.update(tempvars)
            return self._template( **tdict )

    class MonitoredPage( QWebPage ):

        def __init__( self, parent=None ):
            QWebPage.__init__( self, parent )

        def javaScriptAlert( self, frame, msg ):
            print "Alert:",msg

        def javaScriptConsoleMessage( self, message, lineno, srcid ):
            print "Message: ",message," (",srcid,":",lineno,")"

    def __init__( self, controller=None, parent=None ):
        QWebView.__init__(self,parent)
        self._controller = controller
        if not self._controller:
            from Controller import Controller
            self._controller = Controller.instance()
        self._basedir=os.path.dirname(os.path.abspath(__file__))
        self._templatedir = os.path.join(self._basedir,'html')
        self._baseurl = QUrl.fromLocalFile(os.path.join(self._basedir,'html/'))
        self._templates={}
        self._template=None
        self._tempvars={}
        self._nameId = None
        self._name = None
        self._editingName = False
        self._isDirty = False
        self.setPage(self.MonitoredPage(self))
        self._frame = self.page().mainFrame()
        self._frame.javaScriptWindowObjectCleared.connect( self.setFrameController )
        self.setFrameController()

    def setController( self, controller ):
        self._controller = controller

    def setFrameController( self ):
        self._frame.addToJavaScriptWindowObject( "qcontroller", self )

    def closeEvent( self, event ):
        QWebView.closeEvent( self, event )
        if self._isDirty and self._name:
            name = self._name.name
            if len(name) > 23:
                name=name[:20]+'...'
            msg = "You haven't saved changes for " + name + "\nDo you want to continue working?"
            result = QMessageBox.question( self, "Continue working?", msg,
                         QMessageBox.Yes | QMessageBox.No, QMessageBox.Yes )
            if result == QMessageBox.Yes:
                event.ignore()
            else:
                event.accept()
        else:
            event.accept()

        
    def template( self, name ):
        '''
        Retrieves a web page template from the cache
        '''
        if name not in self._templates:
            self._templates[name] = NameWebView.Template( name, self._templatedir )
        return self._templates[name]
        
    def getData(self):
        '''
        Retrieves the data loaded by the template.
        '''
        if self._template:
            data = self._template.editdata()
            return json.dumps(data, default=self.jsonHandler )
        return '{}'

    pageData = pyqtProperty( str, fget=getData );

    nztm_patterns=[''.join(p.split()) for p in [
        r'''^\s*((?:1\d|20)\d{5}(?:\.\d+)?)
             \s+((?:4[6-9]|5\d|6[012])\d{5}(?:\.\d+)?)\s*$''',
        r'''^\s*((?:4[6-9]|5\d|6[012])\d{5}(?:\.\d+)?)
             \s+((?:1\d|20)\d{5}(?:\.\d+)?)\s*$''',
        ]]
    nztm_re=[re.compile(p) for p in nztm_patterns]

    def getCoords( self, value ):
        ll = dms.parse_lonlat(value)
        if ll:
            return (ll,4167)
        for p in self.nztm_re:
            m = p.match(value)
            if m: break
        if m:
            c1=float(m.group(1))
            c2=float(m.group(2))
            coords = [c1,c2] if c1 < c2 else [c2,c1]
            return (coords,2193)
        return None

    @pyqtSlot(str)
    def applyUpdates( self, editjson ):
        '''
        Applies a set of updates encoded in a JSON string. 
        There are three elements in the string:
            update
                A set of object attribute ids with new values
            delete
                A set of object ids to delete
            new
                A set of attribute values, with a special attribute
                _item_type define the class of object to create 
                Note special handling of Association
        '''
        # print unicode(editjson).encode('utf8')
        locationUpdated=False
        try:
            editdata=json.loads(unicode(editjson))
            for id, value in editdata['update'].items():
                if value == '':
                    value = None
                if id.endswith('.setLocation'):
                    coords = self.getCoords(value)
                    if not coords:
                        raise ValueError('"'+value+'" is not a valid coordinate')
                    objid = id.split('.')[0]
                    feature = Model.idObject(objid)
                    feature.setLocation(*coords)
                    locationUpdated=True
                else:
                    Model.setObjectAttr( id, value );
            for id in editdata['delete']:
                Database.delete(Model.idObject(id))
            for item in editdata['new']:
                objtype = item['_item_type']
                obj = None
                if objtype == 'Association':
                    obj = self.createAssociation( item )
                else:
                    try:
                        obj = Model.newObject( objtype )
                    except:
                        raise ValueError('Invalid object type '+str(objtype)+' for new object')
                    for attr, value in item.items():
                        if attr != '_item_type':
                            if value == '':
                                value = None
                            obj.__setattr__( attr, value )
                if obj:
                    Database.add( obj )
    
            Database.commit()
        except:
            Database.rollback()
            msg = unicode(sys.exc_info()[1])
            QMessageBox.warning(self,'Update failed','Cannot save changes: '+msg)
            return

        if self._controller:
            self._controller.recordNameEdited( self._nameId, locationUpdated )
        self.reload()

    @pyqtSlot(bool)
    def setEditing( self, editing ):
        self._editingName = editing

    @pyqtSlot(bool)
    def setDirty( self, editing ):
        self._isDirty = editing

    def editing( self ):
        return self._editingName

    @pyqtSlot(int, bool)
    def showNameId( self, id, forcenew ):
        if self._controller:
            self._controller.showNameId( id, forcenew )

    def setNameId( self, id ):
        self._nameId = id
        name = self._controller.getName(id)
        self._name = name
        if not name:
            raise ValueError("Invalid name id requested: " + str(id))
        self._tempvars = {
            'name': name,
            'isfavourite': "true" if self._controller.isFavourite(id) else "false",
            'getAssociations': lambda : self.getNameAssociations( name ),
            'getAssociationTypeOptions': lambda : self.getAssociationTypeOptions(),
            }
        self._template = self.template('name')
        self.reload()
        self.nameChanged.emit(id,name.name)

    def getNameId( self ):
        return self._nameId

    def getName( self):
        return self._name

    def setFavourite( self, favourite ):
        if self._controller and 'name' in self._tempvars:
            self._controller.setFavourite( self._tempvars['name'].name_id, favourite )

    def getFavourite( self ):
        value = False
        if self._controller and 'name' in self._tempvars:
            value = self._controller.isFavourite( self._tempvars['name'].name_id)
        return value

    isFavourite = pyqtProperty( bool, fget=getFavourite, fset=setFavourite )

    def getNameAssociations( self, name ):
        '''
        Compiles the feature and name associations into a single list.  
        The list is a hash of NameWebView.Association objects, with 
        string defining the text of the association, a name object that 
        it is associated with, and an association object (either Feature or
        Name)
        '''
        associations=[]
        f = name.feature
        lookup = Model.SystemCode.lookup
        for assoc in f.associated_to:
            text = lookup('FAST',assoc.assoc_type) or 'is associated with'
            text = text.split('|')[0]
            text = 'This feature '+text
            aname = assoc.feat_to.preferredName()
            associations.append(NameWebView.Association(text,aname,assoc))

        for assoc in f.associated_from:
            text = lookup('FAST',assoc.assoc_type) or 'is associated with'
            text = text.split('|')[1] if '|' in text else text
            text = 'This feature '+text
            aname = assoc.feat_from.preferredName()
            associations.append(NameWebView.Association(text,aname,assoc))

        for assoc in name.associated_to:
            text = lookup('NAST',assoc.assoc_type) or 'is associated with'
            text = text.split('|')[0]
            text = 'This name '+text
            aname = assoc.name_to
            associations.append(NameWebView.Association(text,aname,assoc))

        for assoc in name.associated_from:
            text = lookup('NAST',assoc.assoc_type) or 'is associated with'
            text = text.split('|')[1] if '|' in text else text
            text = 'This name '+text
            aname = assoc.name_from
            associations.append(NameWebView.Association(text,aname,assoc))

        return associations

    def getAssociationTypeOptions( self ):
        ''' 
        Generate a list of codes representing the various types of 
        associations possible.  Each option encodes whether it is a
        name or feature association, whether it is a reverse option,
        and the association type code as (eg FEAT_R_SBRB).  These are
        used in the applyUpdates function to generate the appropriate 
        member values for constructing new lookup codes.
        '''
        options=[]

        for atype in Model.SystemCode.codeGroup( 'FAST' ):
            text = atype.value
            if atype.category == 'ASYM':
                text = text.split('|',1)
                options.append(('FAST_F_'+atype.code,'This feature '+text[0]))
                options.append(('FAST_R_'+atype.code,'This feature '+text[-1]))
            else:
                options.append(('FAST_F_'+atype.code,'This feature '+text))

        for atype in Model.SystemCode.codeGroup( 'NAST' ):
            text = atype.value
            if atype.category == 'ASYM':
                text = text.split('|',1)
                options.append(('NAST_F_'+atype.code,'This name '+text[0]))
                options.append(('NAST_R_'+atype.code,'This name '+text[-1]))
            else:
                options.append(('NAST_F_'+atype.code,'This name '+text))
        return NameWebView.Template.selectOptions(options)
                
    def createAssociation( self, item ):
        assoc_type = item['assoc_type']
        parts = assoc_type.split('_')
        if len(parts) != 3:
            return None
        nf = Model.Name.get(item['name_id_from'])
        nt = Model.Name.get(item['name_id_to'])
        if parts[1] == 'R':
            ntmp = nf; nf=nt; nt=ntmp
        assoc = None
        if parts[0] == 'NAST':
            assoc = Model.NameAssociation()
            assoc.name_id_from = nf.name_id
            assoc.name_id_to = nt.name_id
        else:
            assoc = Model.FeatureAssociation()
            assoc.feat_id_from = nf.feat_id
            assoc.feat_id_to = nt.feat_id
        assoc.assoc_type=parts[2]
        return assoc

    def getViewedNames( self ):
        names = []
        for name in sorted(self._controller.getViewedNames(),key=lambda x: x.name):
            if name.feat_id != self._name.feat_id:
                names.append({ 'name_id': name.name_id, 'name': name.name })
        return json.dumps(names)

    viewedNames = pyqtProperty( unicode, fget=getViewedNames )

    def getNameAnnotationValidators( self ):
        validators={}
        for c in Model.SystemCode.codeGroup('APNV'):
            validators[c.code] = { 're': c.value, 'message': c.description }
        return json.dumps(validators)

    nameAnnotationValidators = pyqtProperty( unicode, fget=getNameAnnotationValidators )

    def getFeatAnnotationValidators( self ):
        validators={}
        for c in Model.SystemCode.codeGroup('APFV'):
            validators[c.code] = { 're': c.value, 'message': c.description }
        return json.dumps(validators)

    featAnnotationValidators = pyqtProperty( unicode, fget=getFeatAnnotationValidators )

    def getEventReferenceValidators( self ):
        validators={}
        for c in Model.SystemCode.codeGroup('APEV'):
            validators[c.code] = { 're': c.value, 'message': c.description }
        return json.dumps(validators)

    eventReferenceValidators = pyqtProperty( unicode, fget=getEventReferenceValidators )

    def getEventTypes( self ):
        mapping = Model.SystemCode.codeMapping('AUTH')
        mlist = [{'code':c,'value':v} for c,v in mapping.items()]
        mlist.sort( key=lambda x:x['value'] )
        return json.dumps(mlist)

    eventTypes = pyqtProperty( unicode, fget=getEventTypes )

    def getEventTypeAuthorities( self ):
        authorities={}
        mapping = Model.SystemCode.codeMapping('APEA')
        for c, v in mapping.items():
            authorities[c]=v
        return json.dumps(authorities)

    eventTypeAuthorities = pyqtProperty( unicode, fget=getEventTypeAuthorities )

    def getStatuses( self ):
        mapping = Model.SystemCode.codeMapping('NSTS')
        mlist = [{'code':c,'value':v} for c,v in mapping.items()]
        mlist.sort( key=lambda x:x['value'] )
        return json.dumps(mlist)

    statuses = pyqtProperty( unicode, fget=getStatuses )

    def getProcessStatuses( self ):
        processes = {}
        mapping = Model.SystemCode.codeMapping('NPST')
        for c, v in mapping.items():
            processes[c] = v.split()
        return json.dumps(processes)

    processStatuses = pyqtProperty( unicode, fget=getProcessStatuses )

    def getFeatureTypes( self ):
        types=[]
        for r in Model.SystemCode.codeGroup('FTYP'):
            types.append({'code':r.code, 'category':r.category, 'value':r.value})
        types.sort(key=lambda x: x['value'].lower())
        return json.dumps(types)

    featureTypes = pyqtProperty( unicode, fget=getFeatureTypes )

    def getCoordValidators( self ):
        validators = []
        validators.extend(dms.latlon_patterns)
        validators.extend(self.nztm_patterns)
        return json.dumps(validators)

    coordValidators=pyqtProperty( unicode, fget=getCoordValidators )

    @pyqtSlot()
    def reload( self ):
        if not self._template:
            return
        html = self._template.expand( self._tempvars )
        #*****************************************
        # Debug code
        if self.Debug:
            import codecs
            with codecs.open(os.path.join(self._basedir,"html","dump.html"),"w","utf8") as f:
                f.write(html)
            QWebSettings.clearMemoryCaches()
        #*****************************************
        self._editingName = False
        self._isDirty = False
        self._frame.setHtml(html, self._baseurl)

#============================================================

class NameWebDock( QDockWidget ):        

    nameChanged = pyqtSignal(int,str,name="nameChanged")
    closed = pyqtSignal(name="closed")

    def __init__( self, controller=None, parent=None ):
        QDockWidget.__init__( self, "No name", parent )
        self.setAttribute( Qt.WA_DeleteOnClose )
        self._nameWidget = NameWebView( controller, self )
        self.setWidget(self._nameWidget )
        self._nameWidget.nameChanged.connect(self.showName)

    def setNameId( self, id ):
        self._nameWidget.setNameId(id)

    def getNameId( self ):
        return self._nameWidget.getNameId()

    def getName( self ):
        return self._nameWidget.getName()

    def editing( self ):
        return self._nameWidget.editing()

    def showName( self, id, name ):
        title=name
        if len(title) > 22:
            title = title[:20] + '...'
        self.setWindowTitle(title)
        self.nameChanged.emit(id,name)

    def closeEvent( self, event ):
        self._nameWidget.closeEvent( event )
        if not event.isAccepted():
            return
        QDockWidget.closeEvent( self, event )
        self.closed.emit()

