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


import os

from qgis.PyQt.QtWidgets import QDialog

from qgis.core import Qgis

from .LINZ.gazetteer.gui import FormUtils

from .Ui_NewFeatureDialog import Ui_NewFeatureDialog

# Set window to modal for better UX.
# Can also be set to "show" so that the
# modal window does not block tests
MODALITY = os.environ.get("MODALITY", "exec_")


class NewFeatureDialog(QDialog, Ui_NewFeatureDialog):
    @staticmethod
    def createNewFeature(lon, lat, controller, iface):
        iface.dlg_create_new = NewFeatureDialog(iface, controller)
        iface.dlg_create_new.setLocation(lon, lat)
        getattr(iface.dlg_create_new, MODALITY)()

    def __init__(self, iface, controller, parent=None):
        QDialog.__init__(self, parent)
        self.iface = iface
        self.controller = controller
        self._featname = ""
        self.setupUi(self)
        self.uFeatTypeClass.currentIndexChanged.connect(
            lambda x: self._populateFeatureType()
        )
        FormUtils.populateCodeCombo(self.uFeatTypeClass, "FCLS")

    def _populateFeatureType(self):
        fcls = None
        index = self.uFeatTypeClass.currentIndex()
        if index >= 0:
            fcls = str(self.uFeatTypeClass.itemData(index))
        FormUtils.populateCodeCombo(self.uFeatType, "FTYP", category=fcls)

    def featureType(self):
        index = self.uFeatType.currentIndex()
        if index >= 0:
            return str(self.uFeatType.itemData(index))
        return None

    def featureName(self):
        return str(self.uFeatName.text()).strip()

    def setLocation(self, lon, lat):
        self.uLongitude.setText(str(lon))
        self.uLatitude.setText(str(lat))

    def getLocationWkt(self):
        return (
            "POINT("
            + str(self.uLongitude.text())
            + " "
            + str(self.uLatitude.text())
            + ")"
        )

    def accept(self):
        errors = []
        if self.featureName() == "":
            errors.append("You must enter a name for the new feature")
        try:
            lon = float(str(self.uLongitude.text()))
            if lon < 0 or lon > 360:
                errors.append("The longitude must be in the range 0 to 360 degrees")
        except:
            errors.append("The longitude must be a number")
        try:
            lat = float(str(self.uLatitude.text()))
            if lat < -90 or lat > 90:
                errors.append("The latitude must be in the range -90 to 90 degrees")
        except:
            errors.append("The latitude must be a number")

        if errors:
            self.iface.messageBar().pushMessage(
                "New feature errors",
                "\n".join(errors),
                level=Qgis.Critical,
                duration=10,
            )
        else:
            pointwkt = self.iface.dlg_create_new.getLocationWkt()
            self.controller.createNewFeature(
                self.iface.dlg_create_new.featureName(),
                self.iface.dlg_create_new.featureType(),
                pointwkt,
            )
            self.iface.dlg_create_new.close()
