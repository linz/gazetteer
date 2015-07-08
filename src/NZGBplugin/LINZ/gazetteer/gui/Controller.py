
import re

from PyQt4.QtCore import *
from PyQt4.QtGui import *

import DatabaseConfiguration

from LINZ.gazetteer import Database
from LINZ.gazetteer.Model import *
from NameWebView import NameWebDock

class Controller( QObject ):
    '''
    Controller manages interactions between components of the gazetteer application
    by providing a set of events
    '''
    
    recentUpdated = pyqtSignal()
    favouritesUpdated = pyqtSignal()
    mapExtentsChanged = pyqtSignal()
    nameViewCreated = pyqtSignal( QDockWidget )
    viewNameId = pyqtSignal( int )
    nameEdited = pyqtSignal( int )
    featureLocationEdited = pyqtSignal( int )
    searchResultsUpdated = pyqtSignal( str )
    
    _controller = None
    
    @staticmethod
    def instance():
        if Controller._controller == None:
            Controller._controller = Controller( QApplication.instance() )
        return Controller._controller
            
    def __init__(self, parent=None):
        QObject.__init__( self, parent )
        self._mainWindow = None
        self._mapExtents = None
        self._name_id = None
        self._searchResults = []

    def setMainWindow( self, widget ):
        self._mainWindow = widget

    def database( self ):
        return Database

    def mapExtentsNZGD2000( self ):
        return self._mapExtents

    def setMapExtentsNZGD2000( self, extentsWkt ):
        self._mapExtents = extentsWkt
        self.mapExtentsChanged.emit()

    @classmethod
    def databaseConfiguration( self ):
        return Database.getConnection()

    @pyqtSlot( int )
    def isFavourite( self, name_id ):
        result = Database.scalar('select gazetteer.gapp_is_favourite(:name_id)',name_id=name_id)
        return bool(result)

    @pyqtSlot( int, bool )
    def setFavourite( self, name_id, favourite=True ):
        if favourite:
            Database.execute(Database.func.gazetteer.gapp_set_favourite(name_id))
        else:
            Database.execute(Database.func.gazetteer.gapp_clear_favourite(name_id))
        self.favouritesUpdated.emit()
        
    def recent( self, allusers=False, editonly=False, maxnames=50 ):
        results = Database.querysql('select * from gazetteer.gapp_get_recent_names(:allusers,:editonly,:nmax) order by use_date desc, name',
                       allusers=True if allusers else False,
                       editonly=True if editonly else False,
                       nmax=maxnames).fetchall()
        return results

    def favourites( self ):
        results = Database.querysql('select * from gazetteer.gapp_get_favourites() order by name').fetchall()
        return results

    def createNewFeature( self, name, ftype, pointwkt ):
        # Possibly should do this through object model ... but this works!
        name_id = Database.scalar( 'select gazetteer.gaz_CreateNewFeature( :name, :ftype, :wkt )',
                                  name=name, ftype=ftype, wkt=pointwkt )
        self.showNameId( name_id )

    def getName( self, name_id ):
        name = Name.get(name_id)
        Database.execute(Database.func.gazetteer.gapp_record_viewed(name_id))
        self.recentUpdated.emit()
        return name

    def recordNameEdited( self, name_id, locationUpdated=False ):
        Database.execute(Database.func.gazetteer.gapp_record_edited(name_id))
        self.recentUpdated.emit()
        self.nameEdited.emit( name_id )
        if locationUpdated:
            feat_id = Name.get(name_id).feat_id
            self.featureLocationEdited.emit( feat_id )

    def getNameViews( self ):
        views = []
        for top in QApplication.topLevelWidgets():
            for view in top.findChildren(NameWebDock):
                views.insert(0,view)
        return views

    def getViewedNames( self ):
        return [v.getName() for v in self.getNameViews() if v.getName()]

    def showNameId( self, name_id, forcenew=False ):
        nameview = None
        targetview = None
        for view in self.getNameViews():
            if view.getNameId() == name_id:
                nameview = view
                break
            if not forcenew and targetview == None and not view.editing():
                targetview = view

        if not nameview:
            if not targetview:
                targetview = NameWebDock(self, self._mainWindow)
                self.nameViewCreated.emit(targetview)
            targetview.setNameId( name_id )
            nameview = targetview

        nameview.show()
        nameview.raise_()
        self._name_id = name_id
        self.viewNameId.emit(name_id)

    def currentName( self ):
        if self._name_id == None:
            return
        return Name.get( self._name_id )

    def showFeatId( self, feat_id, forcenew=False ):
        for r in self._searchResults:
            if r['feat_id'] == feat_id:
                self.showNameId( r['name_id'], forcenew )
                return
        f = Feature.get(feat_id)
        if f:
            name_id = f.preferredName().name_id
            self.showNameId( name_id, forcenew )

    def setSearchResults( self, results ):
        self._searchResults = results
        ids = set([r['feat_id'] for r in results])
        idstring = ','.join(str(id) for id in ids)
        self.searchResultsUpdated.emit(idstring)
