import unittest


from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qgis.core import QgsProject, QgsPointXY, QgsRectangle, QgsGeometry
from qgis.utils import plugins, iface, reloadPlugin
from PyQt5.QtTest import QTest
from qgis.gui import QgsMapTool

from utils.data_handler import TestDataHandler


class TestNewFeature(unittest.TestCase):
    """
    Test the creating of a new feature and
    editing of values of this new feature
    """

    @classmethod
    def setUpClass(cls):

        # # Insert required sys_codes to allow new feature creation
        cls.data_handler = TestDataHandler()
        cls.data_handler.insert_sys_codes()

        # When running in QGIS via the script assistant
        # Plugin by setting a voluntary_wait > 0 the tester
        # can see the tests run in a way that is visually followable.
        cls.voluntary_wait = 1000

        # Start plugin
        if not plugins.get("NZGBplugin"):
            pass
        else:
            cls.gazetteer_plugin = plugins.get("NZGBplugin")
            cls.gazetteer_plugin._runaction.trigger()

    @classmethod
    def tearDownClass(cls):
        """
        runs at TestCase teardown.
        """
        # Reset the plugin state so next tests start
        # With a plugin state

        # # Reload
        # reloadPlugin("NZGBplugin")

        # # Reload leaves a detached _editorDock - Remove it
        # # As not to end up with duplicates when each suite run
        # cls.gazetteer_plugin._editorDock.close()

        # # Removed required sys_codes when finished
        # # cls.data_handler.delete_sys_codes()

        # # Remove all layers
        # QgsProject.instance().removeAllMapLayers()

        # # And layer groups
        # root = QgsProject.instance().layerTreeRoot()
        # for group in [child for child in root.children() if child.nodeType() == 0]:
        #     root.removeChildNode(group)

    def setUp(cls):
        """
        Runs before each test.
        """

    def tearDown(cls):
        """
        Runs after each test
        """
        pass

    def init_feature(self, feature_name="Geom_test", lat=-41.555556, lon=174.555556):
        """
        Add a feature for geom edit tool testing
        """

        # Click on map canvas
        self.gazetteer_plugin._newfeat.trigger()
        widget = iface.mapCanvas().viewport()
        canvas_point = QgsMapTool(iface.mapCanvas()).toCanvasCoordinates
        QTest.mouseClick(
            widget, Qt.LeftButton, pos=canvas_point(QgsPointXY(lon, lat)), delay=0
        )
        QTest.qWait(500)

        # Fill out new feature form
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()
        QTest.qWait(1000)

    def move_point(self, x, y):

        widget = iface.mapCanvas().viewport()
        canvas_point = QgsMapTool(iface.mapCanvas()).toCanvasCoordinates
        print("move to new pos")
        QTest.mouseMove(widget, pos=canvas_point(QgsPointXY(x, y)), delay=1)
        print("click new pos")

        QTest.mouseClick(
            widget, Qt.LeftButton, pos=canvas_point(QgsPointXY(x, y)), delay=1
        )

    def save_geom(self):
        self.gazetteer_plugin._editsave.trigger()

    @staticmethod
    def activeModalWindowAccept():

        window = QApplication.instance().activeModalWidget()
        window.button(QMessageBox.Yes).click()

    @staticmethod
    def activeModalWindowReject():

        window = QApplication.instance().activeModalWidget()
        window.reject()

    # def test_A_geom_tools_enabled(self):
    #     """
    #     When a plugin is select in the UI form geom edit button should be enabled
    #     The name of the feature should also be shown in the menu bar line edit
    #     """

    #     # Add a feature to test the geom tools against
    #     self.init_feature()

    #     # Should be disabled
    #     self.assertEquals(self.gazetteer_plugin._editcancel.isEnabled(), False)
    #     self.assertEquals(self.gazetteer_plugin._editsave.isEnabled(), False)
    #     self.assertEquals(self.gazetteer_plugin._ptraction.isEnabled(), False)

    #     # True
    #     self.assertEquals(self.gazetteer_plugin._delselaction.isEnabled(), True)
    #     self.assertEquals(self.gazetteer_plugin._addselaction.isEnabled(), True)
    #     self.assertEquals(self.gazetteer_plugin._editnew.isEnabled(), True)
    #     self.assertEquals(self.gazetteer_plugin._editnodes.isEnabled(), True)
    #     self.assertEquals(self.gazetteer_plugin._editshift.isEnabled(), True)

    #     # And check the Qline edit has the feature name populated
    #     self.assertEquals(self.gazetteer_plugin._currNameLabel.text(), "Geom_test")

    def test_B_move_feature(self):
        """
        Move a feature
        """

        self.init_feature("Geom_test")

        # zoom to test location
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.55264656290535,
            -41.55387872892347,
            174.5714208819715,
            -41.570869649805445,
        )
        canvas.setExtent(zoom_rectangle)
        canvas.refresh()

        QTest.qWait(500)

        # Test the feature is where expected
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature refpt")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[0]
        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.55556, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.55556, places=3)

        # Check the database point is as expect
        db_feature_record = self.data_handler.get_feature_by_id(feat_id)
        ewkt = db_feature_record[0][6]
        wkt = ewkt.split(";")[1]
        point = QgsGeometry.fromWkt(wkt).asPoint()
        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.55556, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.55556, places=3)

        widget = iface.mapCanvas().viewport()
        canvas_point = QgsMapTool(iface.mapCanvas()).toCanvasCoordinates
        from_x = 174.55556
        from_y = -41.55556
        to_x = 174.566666
        to_y = -41.566666

        self.gazetteer_plugin._editshift.trigger()
        QTest.qWait(500)
        self.assertEquals(self.gazetteer_plugin._editshift.isEnabled(), True)

        QTimer.singleShot(300, lambda: self.move_point(to_x, to_y))
        print("move to select point")

        QTest.mouseMove(widget, pos=canvas_point(QgsPointXY(from_x, from_y)), delay=1)

        print("left click to select point")

        QTest.mouseClick(
            widget,
            Qt.LeftButton,
            pos=canvas_point(QgsPointXY(from_x, from_y)),
            delay=20,
        )
        QTest.qWait(1000)

        # Test the feature has been moved
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature refpt")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.56666, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.56666, places=3)

        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()

        QTest.qWait(1500)

        # Check the database has updated
        db_feature_record = self.data_handler.get_feature_by_id(feat_id)
        ewkt = db_feature_record[0][6]
        wkt = ewkt.split(";")[1]
        point = QgsGeometry.fromWkt(wkt).asPoint()
        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.56666, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.56666, places=3)

    # def test_C_move_feature_and_discard(self):
    #     """
    #     Move a feature and then discard the edit
    #     """

    #     layer = QgsProject.instance().mapLayersByName("Gazetteer feature line")[0]
    #     iface.setActiveLayer(layer)

    #     gazetteer_plugin = plugins.get("NZGBplugin")

    #     # start new geom tool
    #     gazetteer_plugin._editnew.trigger()

    #     # zoom to test location
    #     canvas = iface.mapCanvas()
    #     zoom_rectangle = QgsRectangle(
    #         174.55264656290535,
    #         -41.55387872892347,
    #         174.5714208819715,
    #         -41.570869649805445,
    #     )
    #     canvas.setExtent(zoom_rectangle)
    #     canvas.refresh()
    #     QTest.qWait(500)

    #     # Start Clicking
    #     widget = iface.mapCanvas().viewport()
    #     canvas_point = QgsMapTool(iface.mapCanvas()).toCanvasCoordinates

    #     QTest.mouseClick(
    #         widget,
    #         Qt.LeftButton,
    #         pos=canvas_point(QgsPointXY(174.54379956, -41.56390752)),
    #         delay=200,
    #     )
    #     QTest.mouseClick(
    #         widget,
    #         Qt.LeftButton,
    #         pos=canvas_point(QgsPointXY(174.56282111, -41.56113095)),
    #         delay=200,
    #     )
    #     QTest.mouseClick(
    #         widget,
    #         Qt.LeftButton,
    #         pos=canvas_point(QgsPointXY(174.58026788, -41.55843727)),
    #         delay=500,
    #     )
    #     QTest.mouseClick(
    #         widget,
    #         Qt.RightButton,
    #         pos=canvas_point(QgsPointXY(174.58026788, -41.55843727)),
    #         delay=500,
    #     )

    #     # Need click ok on Gazetter Feature Line dlg

    # def test_move_feature_and_discard(self):
    #     """
    #     Move a feature and then discard the edit
    #     """
    #     pass

    # def test_move_feature_nodes(self):
    #     """
    #     Move a features node
    #     """
    #     pass

    # def test_error_capture_point(self):
    #     """
    #     With no layers selected select the new feature geom tool
    #     """
    #     pass

    # def test_add_new_geom_cancel(self):
    #     pass

    # def test_add_new_geom_save(self):
    #     pass

    # def test_add_new_geom_(self):
    #     pass

