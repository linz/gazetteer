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


from PyQt4.QtCore import *
from PyQt4.QtGui import *

from qgis.core import *
from qgis.gui import *


class SelectNameTool( QgsMapTool ):

    tolerance = 5
    featureSelected = pyqtSignal( int, name="featureSelected" )

    def __init__( self, iface, layers ):
        QgsMapTool.__init__(self, iface.mapCanvas())
        self._iface = iface
        self._layers = layers
        self._statusbar = self._iface.mainWindow().statusBar()
        from LINZ.gazetteer.gui.Controller import Controller
        self._controller = Controller.instance()

    def activate(self):
        QgsMapTool.activate(self)
        self._statusbar.showMessage("Hover to display name, click to select")
    
    def getIdName( self, pt ):
        tol = self.tolerance
        mapbl = self.toMapCoordinates( QPoint(pt.x()-tol,pt.y()+tol))
        maptr = self.toMapCoordinates( QPoint(pt.x()+tol,pt.y()-tol))
        maprect = QgsRectangle(mapbl,maptr)
        return self._layers.searchResultAtLocation( maprect )

    def canvasMoveEvent(self,e):
        feat_id, name = self.getIdName( e.pos() )
        self._statusbar.showMessage(name or '')
        return

    def canvasReleaseEvent(self,e):
        if not e.button() == Qt.LeftButton:
            return
        feat_id, name = self.getIdName( e.pos() )
        if feat_id:
            self._controller.showFeatId( feat_id, (QApplication.keyboardModifiers() & Qt.ShiftModifier)==Qt.ShiftModifier)
