from __future__ import absolute_import
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


from builtins import str
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from qgis.core import *

from .LINZ.gazetteer.gui.Controller import Controller
from .LINZ.gazetteer.gui import FormUtils

from .Ui_NewFeatureDialog import Ui_NewFeatureDialog

class NewFeatureDialog( QDialog, Ui_NewFeatureDialog ):

    @staticmethod
    def createNewFeature( lon,lat, controller ):
        dlg = NewFeatureDialog()
        dlg.setLocation(lon,lat)
        if dlg.exec_() == QDialog.Accepted:
            pointwkt = dlg.getLocationWkt()
            controller.createNewFeature( dlg.featureName(), dlg.featureType(), pointwkt )
    
    def __init__( self, parent=None):
        QDialog.__init__( self, parent )
        self._featname = ''
        self.setupUi(self)
        self.uFeatTypeClass.currentIndexChanged.connect(
            lambda x: self._populateFeatureType()
            )
        FormUtils.populateCodeCombo( self.uFeatTypeClass, 'FCLS')

    def _populateFeatureType( self ):
        fcls = None
        index = self.uFeatTypeClass.currentIndex()
        if index >= 0:
            fcls = str(self.uFeatTypeClass.itemData(index))
        FormUtils.populateCodeCombo( self.uFeatType, 'FTYP', category=fcls )

    def featureType( self ):
        index = self.uFeatType.currentIndex()
        if index >= 0:
            return str(self.uFeatType.itemData(index))
        return None

    def featureName( self ):
        return str(self.uFeatName.text()).strip()

    def setLocation( self, lon, lat ):
        self.uLongitude.setText(str(lon))
        self.uLatitude.setText(str(lat))

    def getLocationWkt( self ):
        return 'POINT('+str(self.uLongitude.text())+' '+str(self.uLatitude.text())+')'

    def accept( self ):
        errors = []
        if self.featureName() == '':
            errors.append('You must enter a name for the new feature')
        try:
            lon=float(str(self.uLongitude.text()))
            if lon < 0 or lon > 360:
                errors.append('The longitude must be in the range 0 to 360 degrees')
        except:
            errors.append('The longitude must be a number')
        try:
            lat=float(str(self.uLatitude.text()))
            if lat < -90 or lat > 90:
                errors.append('The latitude must be in the range -90 to 90 degrees')
        except:
            errors.append('The latitude must be a number')

        if errors:
            QMessageBox.information(self,'New feature errors','\n'.join(errors))
        else:
            # feat_type.show()
            QDialog.accept(self)
