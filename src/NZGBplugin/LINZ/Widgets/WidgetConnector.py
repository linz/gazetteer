################################################################################
#
# Copyright 2015 Crown copyright (c)
# Land Information New Zealand and the New Zealand Government.
# All rights reserved
#
# This program is released under the terms of the new BSD license. See the 
# LICENSE file for more information.
#
################################################################################


from PyQt4.QtCore import *
from PyQt4.QtGui import *
import sys

from Adaptor import Adaptor


class WidgetLinker( QObject ):

    dataChanged = pyqtSignal()

    def __init__( self, widget ):
        QObject.__init__(self)
        self._widget = widget
        self._attrdef = None
        self._adaptor = None
        self._attribute = None

    def setAttribute( self, adaptor, attribute ):
        self._adaptor = adaptor
        self._attribute = attribute
        self._attrdef = None
        try:
            self._attrdef = adaptor.getAttrDef(attribute)
        except:
            pass

    def emitChanged( self ):
        self.dataChanged.emit()

    # Put here to handle non-editable things...
    def readOnly( self ):
        return False

    @staticmethod
    def getLinker( widget ):
        for c in WidgetLinker.__subclasses__():
            if 'types' in dir(c):
                for t in c.types:
                    if isinstance(widget,t):
                        return c(widget)
        return None

class ComboLinker( WidgetLinker ):

    types = [QComboBox]

    def __init__( self, widget ):
        WidgetLinker.__init__(self, widget)
        widget.currentIndexChanged[int].connect(lambda x: self.emitChanged())

    def getValue( self ):
        index = self._widget.currentIndex()
        if index >= 0:
            result = self._widget.itemData( index )
            return result
        else:
            return None

    def setValue( self, value ):
        index = self._widget.findData( value )
        self._widget.setCurrentIndex( index )

class LabelLinker( WidgetLinker ):

    types = [QLabel]

    def __init__( self, widget ):
        WidgetLinker.__init__(self, widget)

    def getValue( self ):
        return self._widget.text()

    def setValue( self, value ):
        self._widget.setText( unicode(value) if value else u'' )
        
class LineEditLinker( WidgetLinker ):

    types = [QLineEdit]
    
    def __init__( self, widget ):
        WidgetLinker.__init__(self, widget)
        widget.textChanged.connect(lambda x: self.emitChanged())

    def getValue( self ):
        return self._widget.text()

    def setValue( self, value ):
        self._widget.setText( unicode(value) if value else u'' )

class PlainTextLinker( WidgetLinker ):

    types = [QPlainTextEdit, QTextEdit]
    
    def __init__( self, widget ):
        WidgetLinker.__init__(self, widget)
        widget.textChanged.connect(lambda: self.emitChanged())

    def getValue( self ):
        return unicode(self._widget.toPlainText())

    def setValue( self, value ):
        self._widget.setPlainText( unicode(value) if value else '' )

class TableViewLinker( WidgetLinker ):

    types = [QTableView]

    def __init__( self, widget ):
        WidgetLinker.__init__(self, widget)

    def readOnly( self ):
        return True

    def getValue( self ):
        return None

    def setValue( self, value ):
        from ListModelConnector import ListModelConnector
        if not isinstance(value,list):
            raise RuntimeError("Cannot set "+self._widget.objectName()+" to a non list value")
        model = self._widget.model()
        if not isinstance(model,ListModelConnector):
            atype = self._attrdef.type() if self._attrdef else None
            if not isinstance(atype,Adaptor):
                raise RuntimeError("Cannot create list model for "+self._widget.objectName()+" (don't have an adaptor defined)")
            model = ListModelConnector(adaptor=atype)
            self._widget.setModel(model)
        model.setList( value )

class Linkage( QObject ):

    '''
    Class for linking a specific attribute of an object with a 
    particular widget.
    '''

    dataChanged = pyqtSignal()

    def __init__( self, adaptor, attr, widget ):
        QObject.__init__(self)
        self._adaptor = adaptor
        self._attr = attr
        self._dirty = False

        self._linker = WidgetLinker.getLinker(widget)
        if self._linker:
            self._linker.setAttribute( adaptor, attr )
            self._linker.dataChanged.connect( self.onDataChanged )
        self._value = None

    def load( self, object ):
        self._dirty = False
        if object != None:
            value = self._adaptor.getValue(object,self._attr)
        else:
            value = ''
        self._value = None
        if self._linker != None:
            self._linker.setValue(value)
            self._value = self._linker.getValue()
            self._dirty = False

    def save( self, object, overwrite ):
        if self._linker != None and not self._linker.readOnly():
            try:
                value = self._linker.getValue()
                self._adaptor.setValue(object,self._attr,value,overwrite)
                self._value = value
                self._dirty = False
            except:
                pass

    def isDirty( self ):
        return self._dirty

    def onDataChanged( self ):
        if self._linker and not self._linker.readOnly():
            wasdirty = self._dirty
            self._dirty = self._value != self._linker.getValue()
            if wasdirty != self._dirty:
                self.dataChanged.emit()

class WidgetConnector( QObject ):
    ''' 
    Mixin class for a widget to provide automatic connection with an
    ORM base class from SqlAlchemy.  

    Interrogates the object to determine the field names, then attempts
    to link each field with a child widget of the form with the same 
    name.

    The LoadEntity function and SaveEntity functions provide the main 
    connection between the entity and the object.  The IsDirty function
    determines whether an entity has changed.
    '''

    dataChanged = pyqtSignal( bool )

    def __init__( self, form, adaptor, prefix='' ):
        QObject.__init__(self)
        self._adaptor = None
        self._form = form
        self._widget_prefix = prefix
        self._object = None
        self._mapping = []
        self.setAdaptor( adaptor )

    def load( self, object ):
        self._connectObject( object )
        self.dataChanged.emit( False )

    def save( self, overwrite=False ):
        '''
        Save the object attributes.  The overwrite attribute allows
        readonly attributes (as specified by the adaptor) to be written
        (For example to write primary key values in new objects)
        '''
        
        if self._object:
            for link in self._mapping:
                link.save( self._object, overwrite )
                
    def connectedObject( self ):
        return self._object

    def isDirty( self ):
        if self._object:
            for link in self._mapping:
                if link.isDirty():
                    return True
        return False

    def onDataChanged( self ):
        if self._object != None:
            self.dataChanged.emit( self.isDirty())

    def setAdaptor( self, adaptor ):
        if adaptor == self._adaptor:
            return
        self._adaptor = adaptor
        self._object = None
        self._mapping = []

        for widget in self._form.findChildren(QWidget):          
            attribute = widget.property('dataAttribute')
            if not attribute and self._widget_prefix:
                name = unicode(widget.objectName())
                if not name.startswith(self._widget_prefix):
                    continue
                attribute = name[len(self._widget_prefix):]
            if not attribute:
                continue
            try:
                # Confirm that the attribute belongs to this adaptor
                self._adaptor.getAttrDef(unicode(attribute))
                linker = Linkage( adaptor, attribute, widget )
                self._mapping.append(linker)
                linker.dataChanged.connect( self.onDataChanged )
            except:
                #a,b,c=sys.exc_info()
                #raise a,b,c
                pass

    def _connectObject( self, object ):
        try:
            self._object = None
            for link in self._mapping:
                link.load( object )
            self._object = object
        except:
            self.object = None
            raise
