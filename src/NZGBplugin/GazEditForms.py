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

from qgis.PyQt.QtWidgets import QWidget, QDialogButtonBox, QMessageBox
from qgis.core import QgsProject, QgsWkbTypes

from LINZ.gazetteer import Model
from LINZ.gazetteer.gui import FormUtils

# def getFeatureAttributes( layerId, featureId ):
#     attribs = {}
#     layer = QgsMapLayerRegistry.instance().mapLayer( layerId )
#     feat = QgsFeature()
#     if layer.featureAtId(featureId,feat,False,True):
#         fields = layer.dataProvider().fields()
#         for idx in fields:
#             flddef = fields[idx]
#             name = str(flddef.name())
#             value = feat.attributeMap()[idx].toPyObject()
#             attribs[name] = value
#     return attribs


def openFeatRefPointForm(dlg, layerId, featureId):
    newFeature = featureId == 0
    label = dlg.findChild(QWidget, "action_label")
    name = dlg.findChild(QWidget, "name")
    feat_type = dlg.findChild(QWidget, "feat_type")
    feat_type_combo = dlg.findChild(QWidget, "feat_type_combo")
    buttons = dlg.findChild(QWidget, "buttonBox")
    feat_type.hide()
    name.setEnabled(newFeature)
    feat_type_combo.setEnabled(newFeature)
    FormUtils.populateCodeCombo(feat_type_combo, "FTYP")

    if newFeature:
        name.setText("")
        feat_type_combo.setCurrentIndex(0)
        label.setText("Enter the name and type of the new feature")
        buttons.setStandardButtons(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
    else:
        index = feat_type_combo.findData(feat_type.text())
        feat_type_combo.setCurrentIndex(index)
        label.setText(
            "Use the gazetteer edit form to update information for existing features"
        )
        buttons.setStandardButtons(QDialogButtonBox.Ok)

    def setFeatType(index):
        index = feat_type_combo.currentIndex()
        if index >= 0:
            feat_type.setText(feat_type_combo.itemData(index))

    def validate():
        if not newFeature:
            dlg.reject()
            return
        featname = str(name.text()).strip()
        if name.text() == "":
            QMessageBox.information(
                dlg, "Name missing", "You must enter a name for the new feature"
            )
        else:
            # feat_type.show()
            dlg.accept()

    setFeatType(0)
    feat_type_combo.currentIndexChanged.connect(setFeatType)
    buttons.accepted.disconnect(dlg.accept)
    buttons.accepted.connect(validate)


def openFeatGeomForm(dlg, lyr, feature):
    label = dlg.findChild(QWidget, "action_label")
    feat_id = dlg.findChild(QWidget, "feat_id")
    feat_id.hide()
    layerId = lyr.id()
    featureId = feature.id()
    layer = QgsProject.instance().mapLayer(layerId)
    ss = layer.subsetString()
    if ss and ss.startswith("feat_id="):
        # SJ: QString method changed
        feat_id.setText(ss[8:])
    layer = QgsProject.instance().mapLayer(layerId)
    type = layer.wkbType()
    if type == QgsWkbTypes.MultiPoint:
        stype = "point"
    elif type == QgsWkbTypes.MultiLineString:
        stype = "line"
    else:
        stype = "polygon"
    label.setText("Add new " + stype)  # +' to ' + name.name )
