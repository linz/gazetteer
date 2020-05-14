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
import os.path

from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *

from qgis.core import *

from .LINZ.gazetteer.gui.Controller import Controller


class Layers(QObject):

    startEdit = pyqtSignal(name="startEdit")
    endEdit = pyqtSignal(name="endEdit")
    nameSelected = pyqtSignal(str, name="nameSelected")

    _layerDefs = [
        {
            "id": "fpoly",
            "group": "feature",
            "table": "feature_polygon",
            "geom": "shape",
            "key": "geom_id",
            "form": "featgeom.ui",
            "init": "openFeatGeomForm",
            "wkbtype": QgsWkbTypes.MultiPolygon,
        },
        {
            "id": "fline",
            "group": "feature",
            "table": "feature_line",
            "geom": "shape",
            "key": "geom_id",
            "form": "featgeom.ui",
            "init": "openFeatGeomForm",
            "wkbtype": QgsWkbTypes.MultiLineString,
        },
        {
            "id": "fpoint",
            "group": "feature",
            "table": "feature_point",
            "geom": "shape",
            "key": "geom_id",
            "form": "featgeom.ui",
            "init": "openFeatGeomForm",
            "wkbtype": QgsWkbTypes.MultiPoint,
        },
        {
            "id": "frefpt",
            "group": "feature",
            "table": "feature_ref_point",
            "geom": "ref_point",
            "key": "feat_id",
            "form": "featrefpt.ui",
            "init": "openFeatRefPointForm",
            "wkbtype": QgsWkbTypes.Point,
        },
        {
            "id": "spoly",
            "group": "search",
            "table": "feature_polygon",
            "geom": "shape",
            "key": "geom_id",
            "wkbtype": QgsWkbTypes.MultiPolygon,
        },
        {
            "id": "sline",
            "group": "search",
            "table": "feature_line",
            "geom": "shape",
            "key": "geom_id",
            "wkbtype": QgsWkbTypes.MultiLineString,
        },
        {
            "id": "spoint",
            "group": "search",
            "table": "feature_point",
            "geom": "shape",
            "key": "geom_id",
            "wkbtype": QgsWkbTypes.MultiPoint,
        },
        {
            "id": "srefpt",
            "group": "search",
            "table": "feature_ref_point",
            "geom": "ref_point",
            "key": "feat_id",
            "init": "openFeatRefPointForm",
            "wkbtype": QgsWkbTypes.Point,
        },
    ]

    idProperty = "GazetteerLayerType"
    zoomMargin = 10000
    dbCrsEpsg = 4167
    autoZoom = True
    initModule = "GazEditForms"

    def __init__(self, iface, parent=None):
        QObject.__init__(self, parent)
        self._iface = iface
        self._statusBar = iface.mainWindow().statusBar()
        self._featid = -1
        self._searchIds = []
        self._name = None
        self._layers = {}
        self._dbCrs = QgsCoordinateReferenceSystem()
        self._dbCrs.createFromString("epsg:" + str(Layers.dbCrsEpsg))
        self._layersOk = False
        self._qmldir = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), "styles"
        )
        self._formdir = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), "forms"
        )
        self._controller = Controller.instance()
        self._database = self._controller.database()
        self._transform = None

        # Set up the map extent handling
        self.setExtents()
        self._iface.mapCanvas().extentsChanged.connect(self.setExtents)
        self._iface.mapCanvas().destinationCrsChanged.connect(self.setExtents)

        # Ensure layers are defined with current database URI
        self.setupLayerUris()

        self.createLayers()
        registry = QgsProject.instance()
        registry.layerWillBeRemoved.connect(self.removeLayer)
        iface.projectRead.connect(self.removeLayers)
        iface.newProjectCreated.connect(self.removeLayers)

        self._controller.viewNameId.connect(self.showNameId)
        self._controller.searchResultsUpdated.connect(self.showSearchResults)
        self._controller.featureLocationEdited.connect(self.updateFeatureLocation)

    def setExtents(self):
        # Could be more sophisticated here.  What happens with dateline.  Should we
        # create a set of points around the boundary and transform that to ensure extents
        # are included.
        try:
            canvas = self._iface.mapCanvas()
            extent = canvas.extent()
            transform = QgsCoordinateTransform(
                canvas.mapSettings().destinationCrs(),
                self._dbCrs,
                QgsProject.instance(),
            )
            self._transform = transform
            mapview = transform.transformBoundingBox(extent)
            rect = QgsGeometry.fromRect(mapview)
            wkt = str(rect.asWkt())
            self._controller.setMapExtentsNZGD2000(wkt)
        except:
            raise
            pass

    def setupLayerUris(self):
        conn = self._controller.databaseConfiguration()
        uri = QgsDataSourceUri()
        uri.setConnection(
            conn["host"],
            conn["port"],
            conn["database"],
            conn["user"],
            conn["password"] or "",
        )
        uri.setUseEstimatedMetadata(False)

        for ldef in self._layerDefs:
            id = ldef["id"]
            schema = conn["schema"]
            table = ldef["table"]
            geomcol = ldef["geom"]
            keycol = ldef["key"]
            where = "feat_id=-1"
            uri.setDataSource(schema, table, geomcol, where, keycol)
            uri.setSrid(str(Layers.dbCrsEpsg))
            uri.setWkbType(ldef["wkbtype"])

            self._layers[id] = {
                "id": id,
                "def": ldef,
                "uri": uri.uri(),
                "layer": None,
                "layerid": None,
            }

    def removeLayer(self, layerid):
        for l in self.layerDefs():
            if l["layerid"] == layerid:
                l["layerid"] = None
                l["layer"] = None
        self._layersOk = False

    def removeLayers(self):
        for l in self.layerDefs():
            l["layerid"] = None
            l["layer"] = None
        self._layersOk = False

    def createLayers(self):

        updated = False
        featureGroup = None

        # Initiallize layers
        for glayer in self.layerDefs():
            glayer["layer"] = None

        # Check for existing layers matching data source
        registry = QgsProject.instance()
        for maplayer in list(registry.mapLayers().values()):
            if maplayer.type() != QgsMapLayer.VectorLayer:
                continue
            lyrid = str(maplayer.customProperty(Layers.idProperty))
            if lyrid not in self._layers:
                continue
            glayer = self._layers[lyrid]
            # Check that the data source for the layer is correct
            # If not then remove the layer - it will be replaced with correct
            # data source.
            uri = QgsDataSourceUri(maplayer.dataProvider().dataSourceUri())
            uri.setSql("feat_id=-1")
            if uri.uri() == glayer["uri"]:
                glayer["layer"] = maplayer
                glayer["layerid"] = maplayer.id()
            else:
                registry.removeMapLayer(maplayer.id())
                updated = True

        # Now add missing layers

        ok = True
        for glayer in self.layerDefs():
            layer = glayer["layer"]
            ldef = glayer["def"]
            if not layer:
                group = ldef["group"]
                name = "Gazetteer " + group + " " + glayer["id"][1:]
                layer = QgsVectorLayer(glayer["uri"], name, "postgres")
                if not layer.isValid():
                    QMessageBox.information(
                        self._iface.mainWindow(),
                        "Layer " + name,
                        "Cannot create layer - definition not valid",
                    )
                    ok = False
                    continue
                layer.setSubsetString("feat_id=-1")
                layer.setCustomProperty(Layers.idProperty, glayer["id"])
                glayer["layer"] = layer
                glayer["layerid"] = layer.id()
                qml = os.path.join(self._qmldir, glayer["id"] + ".qml")
                if os.path.exists(qml) or True:
                    try:
                        layer.loadNamedStyle(qml)
                    except:
                        pass
                QgsProject.instance().addMapLayer(layer)
                updated = True
            if "form" in ldef:
                layer.setReadOnly(False)
                editFormConfig = layer.editFormConfig()
                editFormConfig.setUiForm(os.path.join(self._formdir, ldef["form"]))
                editFormConfig.setLayout(editFormConfig.UiFileLayout)
                if "init" in ldef:
                    editFormConfig.setInitFunction(self.initModule + "." + ldef["init"])
                layer.setEditFormConfig(editFormConfig)
            else:
                layer.setReadOnly()

        # If updated, then add layers to group...

        if updated:
            self.moveLayersIntoGroup("search", "Gazetteer search results")
            self.moveLayersIntoGroup("feature", "Gazetteer feature")

        # Find the group
        self._layersOk = ok

    def moveLayersIntoGroup(self, group, title):
        root = QgsProject.instance().layerTreeRoot()
        groups = [group.name() for group in root.findGroups()]

        # check if layer title already exists
        groups = [group.name() for group in root.findGroups()]
        if title not in groups:
            # add group and store ref
            group_ref = root.addGroup(title)
        else:
            # get group ref of already existing group
            group_ref = root.findGroup(title)
        # add layer to group
        for lyr in self.layers(group):
            group_ref.addLayer(lyr)

    # Return layer defs in defined order
    def layerDefs(self):
        for id in [ld["id"] for ld in self._layerDefs]:
            yield self._layers[id]

    def layers(self, group=None):
        for glayer in self.layerDefs():
            if group == None or glayer["def"]["group"] == group:
                yield glayer["layer"]

    def featureLayers(self):
        for layer in self.layers("feature"):
            yield layer

    def featureGeomLayers(self):
        for glayer in self.layerDefs():
            if glayer["def"]["group"] == "feature" and glayer["id"] != "frefpt":
                yield glayer["layer"]

    def searchLayers(self):
        for layer in self.layers("search"):
            yield layer

    def startFeatureEdits(self, addNew=False):
        if not self._name:
            return
        for layer in self.featureLayers():
            if not layer.isEditable():
                layer.startEditing()
        self.selectEditLayer(addNew)
        self.startEdit.emit()

    def selectEditLayer(self, addNew=False):
        currentLayer = self._iface.mapCanvas().currentLayer()
        nfeat = -1
        editlayer = None
        for glayer in self.layerDefs():
            ldef = glayer["def"]
            if ldef["group"] != "feature":
                continue
            if addNew and ldef["id"] == "frefpt":
                continue
            layer = glayer["layer"]
            if currentLayer is not None and layer.id() == currentLayer.id():
                editlayer = layer
                break
            count = layer.featureCount()
            if count > nfeat:
                nfeat = count
                editlayer = layer

        self._iface.mapCanvas().setCurrentLayer(editlayer)
        return editlayer

    def endFeatureEdits(self, cancel=False):
        modified = False
        for layer in self.featureLayers():
            if layer.isModified():
                modified = True
        rollback = True
        if modified and self._name and not cancel:
            message = u"Save spatial changes to " + self._name.name
            result = QMessageBox.question(
                self._iface.mainWindow(),
                "Save spatial changes",
                message,
                QMessageBox.Yes | QMessageBox.No | QMessageBox.Cancel,
            )
            if result == QMessageBox.Cancel:
                return False
            if result == QMessageBox.Yes:
                rollback = False

        for layer in self.featureLayers():
            if layer.isEditable():
                if rollback:
                    layer.rollBack()
                else:
                    if not layer.commitChanges():
                        return False
                    layer.updateExtents()
                    layer.triggerRepaint()
        self.endEdit.emit()
        return True

    def showNameId(self, name_id):
        n = self._controller.getName(name_id)
        if not n:
            return

        if not self._layersOk:
            self.createLayers()

        feat_id = n.feat_id
        if self._featid != feat_id:
            if not self.endFeatureEdits():
                return

            # Need to check for editing
            self._name = None
            self._featid = feat_id
            where = "feat_id=" + str(feat_id)

            for layer in self.featureLayers():
                if layer.subsetString() == where:
                    continue
                layer.setSubsetString(where)
                layer.updateExtents()
                layer.triggerRepaint()

            if self.autoZoom:
                self.zoomToFeature()

        self._name = n
        if self._statusBar:
            self._statusBar.showMessage("Selected " + n.name)
            self.nameSelected.emit(n.name)

    def updateFeatureLocation(self, feat_id):
        if feat_id == self._featid:
            for layer in self.featureLayers():
                layer.triggerRepaint()
        if feat_id in self._searchIds:
            for layer in self.layers("search"):
                layer.triggerRepaint()

    def showSearchResults(self, idstr):
        if not self._layersOk:
            self.createLayers()
        where = "feat_id=-1"
        self._searchIds = []
        if idstr:
            where = "feat_id in (" + idstr + ")"
            self._searchIds = [int(x) for x in str(idstr).replace(",", " ").split()]
        for layer in self.layers("search"):
            if layer.subsetString() == where:
                continue
            layer.setSubsetString(where)
            layer.updateExtents()
            layer.triggerRepaint()

    def transformMapPoint(self, point):
        return self._transform.transform(point)

    def searchResultAtLocation(self, rect):
        if not self._transform:
            return
        extent = self._transform.transformBoundingBox(rect)
        layers = list(self.layers("search"))
        layers.reverse()
        feat = QgsFeature()
        feat_id = None
        name = None
        for layer in layers:
            request = QgsFeatureRequest()
            request.setFilterRect(extent)
            attlist = ["feat_id", "name"]
            fields = layer.fields()
            request.setSubsetOfAttributes(
                [fields.indexFromName(attlist[0]), fields.indexFromName(attlist[1])]
            )
            request.setFlags(QgsFeatureRequest.NoGeometry)
            request.setFlags(QgsFeatureRequest.ExactIntersect)
            # SJ: old vectorLayer API
            # layer.select(attlist,extent,False,True)

            # if layer.nextFeature(feat):
            if layer.getFeatures(request).nextFeature(feat):
                try:
                    feat_id = int(feat[attlist[0]])
                except:
                    feat_id = None
                    continue
                name = feat[attlist[1]]
                break
        return feat_id, name

    def zoomToFeature(self):
        extentWkt = self._database.scalar(
            "select ST_AsText(gazetteer.gaz_featureExtents(:feat_id,:margin))",
            feat_id=self._featid,
            margin=Layers.zoomMargin,
        )
        if not extentWkt:
            return
        if not self._transform:
            return
        canvas = self._iface.mapCanvas()
        geom = QgsGeometry.fromWkt(extentWkt)
        mapview = self._transform.transformBoundingBox(
            geom.boundingBox(), QgsCoordinateTransform.ReverseTransform
        )
        canvas.setExtent(mapview)
        canvas.refresh()

    def addSelectedGeometries(self):
        name = self._controller.currentName()
        if not name:
            QMessageBox.information(
                self._iface.mainWindow(),
                "No feature selected",
                "Cannot add geometries - no feature currently selected",
            )
            return
        feat_id = name.feat_id
        gazlayers = [layer.id() for layer in self.featureLayers()]

        geometries = {}
        for layer in self._iface.mapCanvas().layers():
            if layer.type() != QgsMapLayer.VectorLayer:
                continue
            if layer.id() in gazlayers:
                continue
            geomlist = [f.geometryAndOwnership() for f in layer.selectedFeatures()]
            if geomlist:
                if layer.crs() != self._dbCrs:
                    ct = QgsCoordinateTransform(layer.crs(), self._dbCrs)
                    for g in geomlist:
                        g.transform(ct)
                gtype = layer.geometryType()
                if gtype not in geometries:
                    geometries[gtype] = []
                geometries[gtype].extend(geomlist)

        if not geometries:
            QMessageBox.information(
                self._iface.mainWindow(),
                "No geometry selected",
                "Cannot add geometries - no features are currently selected from non-gazetteer layers",
            )
            return

        gtypes = (
            (QGis.Point, "point", "fpoint"),
            (QGis.Line, "line", "fline"),
            (QGis.Polygon, "polygon", "fpoly"),
        )
        summary = []
        for gtype in gtypes:
            if gtype[0] in geometries:
                summary.append(str(len(geometries[gtype[0]])) + " " + gtype[1] + "s")
        message = "Add " + ", ".join(summary) + " to " + name.name + "?"
        result = QMessageBox.question(
            self._iface.mainWindow(),
            "Add geometries",
            message,
            QMessageBox.Ok | QMessageBox.Cancel,
        )
        if result != QMessageBox.Ok:
            return

        for gtype in gtypes:
            if gtype[0] not in geometries:
                continue
            geomlist = geometries[gtype[0]]
            layer = self._layers[gtype[2]]["layer"]
            fields = layer.pendingFields()
            editable = layer.isEditable()
            if not editable:
                layer.startEditing()
            for g in geomlist:
                f = QgsFeature(fields)
                f.setGeometry(g)
                f["feat_id"] = feat_id
                layer.addFeature(f)
            if not editable:
                layer.commitChanges()
                layer.updateExtents()
                layer.triggerRepaint()

    def deleteSelectedGeometries(self):
        name = self._controller.currentName()
        if not name:
            QMessageBox.information(
                self._iface.mainWindow(),
                "No feature selected",
                "Cannot delete geometries - no feature currently selected",
            )
            return

        geometries = {}
        for layer in self.featureGeomLayers():
            ndel = layer.selectedFeatureCount()
            if ndel == 0:
                continue
            gtype = layer.geometryType()
            if gtype not in geometries:
                geometries[gtype] = 0
            geometries[gtype] += ndel

        if not geometries:
            QMessageBox.information(
                self._iface.mainWindow(),
                "No geometry selected",
                "Cannot delete geometries for feature - none have been selected",
            )
            return

        gtypes = (
            (QGis.Point, "point", "fpoint"),
            (QGis.Line, "line", "fline"),
            (QGis.Polygon, "polygon", "fpoly"),
        )
        summary = []
        for gtype in gtypes:
            if gtype[0] in geometries:
                summary.append(str(geometries[gtype[0]]) + " " + gtype[1] + "s")
        message = "Delete " + ", ".join(summary) + " from " + name.name + "?"
        result = QMessageBox.question(
            self._iface.mainWindow(),
            "Delete geometries",
            message,
            QMessageBox.Ok | QMessageBox.Cancel,
        )
        if result != QMessageBox.Ok:
            return

        for layer in self.featureGeomLayers():
            editable = layer.isEditable()
            if not editable:
                layer.startEditing()
            for id in layer.selectedFeaturesIds():
                layer.deleteFeature(id)
            if not editable:
                layer.commitChanges()
                layer.updateExtents()
                layer.triggerRepaint()
