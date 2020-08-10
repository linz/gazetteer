import unittest


from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qgis.core import (
    QgsProject,
    QgsPointXY,
    QgsRectangle,
    QgsGeometry,
    QgsVectorLayer,
    QgsField,
    QgsFeature,
    QgsLayerTreeLayer,
)
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

        # Insert required sys_codes to allow new feature creation
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

        # Reload
        reloadPlugin("NZGBplugin")

        # Reload leaves a detached _editorDock - Remove it
        # As not to end up with duplicates when each suite run
        cls.gazetteer_plugin._editorDock.close()

        # Removed required sys_codes when finished
        cls.data_handler.delete_sys_codes()

        # Remove all layers
        QgsProject.instance().removeAllMapLayers()

        # And layer groups
        root = QgsProject.instance().layerTreeRoot()
        for group in [child for child in root.children() if child.nodeType() == 0]:
            root.removeChildNode(group)

    def setUp(cls):
        """
        Runs before each test.
        """

        cls.widget = iface.mapCanvas().viewport()
        cls.canvas_point = QgsMapTool(iface.mapCanvas()).toCanvasCoordinates

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
        QTest.mouseClick(
            self.widget,
            Qt.LeftButton,
            pos=self.canvas_point(QgsPointXY(lon, lat)),
            delay=0,
        )
        QTest.qWait(500)

        # Fill out new feature form
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()
        QTest.qWait(1000)

    def click_point(self, x, y, button=Qt.LeftButton):
        """
        Click on map canvas. Defaults to left click.
        """

        QTest.mouseMove(self.widget, pos=self.canvas_point(QgsPointXY(x, y)), delay=15)

        QTest.mouseClick(
            self.widget, button, pos=self.canvas_point(QgsPointXY(x, y)), delay=15
        )

    def move_point(self, from_x, from_y, to_x, to_y):
        """
        Select a point and move it
        """

        QTimer.singleShot(100, lambda: self.click_point(to_x, to_y))

        QTest.mouseMove(
            self.widget, pos=self.canvas_point(QgsPointXY(from_x, from_y)), delay=0
        )

        QTest.mouseClick(
            self.widget,
            Qt.LeftButton,
            pos=self.canvas_point(QgsPointXY(from_x, from_y)),
            delay=10,
        )

    def zoom_to_test_area(self, x_min, y_min, x_max, y_max):
        """
        Zoom to the area the test is being execute.
        This is useful for ensure coordinate rounding position
        when coord are got by mouse click
        """

        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(x_min, y_min, x_max, y_max)
        canvas.setExtent(zoom_rectangle)
        canvas.refresh()

        QTest.qWait(500)

    @staticmethod
    def activeModalWindowAccept():
        """
        Get the current active modal widget and click Yes
        """

        window = QApplication.instance().activeModalWidget()
        window.button(QMessageBox.Yes).click()

    @staticmethod
    def activeModalWindowReject():
        """
        Get the current active modal widget and click No
        """

        window = QApplication.instance().activeModalWidget()
        window.button(QMessageBox.No).click()

    @staticmethod
    def activeModalWindowOk():
        """
        Get the current active modal widget and click Ok
        """

        window = QApplication.instance().activeModalWidget()
        window.button(QMessageBox.Ok).click()

    def test_A_geom_tools_enabled(self):
        """
        When a plugin is select, the UI form geom edit button should be enabled.
        The name of the feature should also be shown in the menu bar line edit
        """

        # Add a feature to test the geom tools against
        self.init_feature()

        # Below tools should be disabled
        self.assertEquals(self.gazetteer_plugin._editcancel.isEnabled(), False)
        self.assertEquals(self.gazetteer_plugin._editsave.isEnabled(), False)
        self.assertEquals(self.gazetteer_plugin._ptraction.isEnabled(), False)

        # Below tools should be enabled
        self.assertEquals(self.gazetteer_plugin._delselaction.isEnabled(), True)
        self.assertEquals(self.gazetteer_plugin._addselaction.isEnabled(), True)
        self.assertEquals(self.gazetteer_plugin._editnew.isEnabled(), True)
        self.assertEquals(self.gazetteer_plugin._editnodes.isEnabled(), True)
        self.assertEquals(self.gazetteer_plugin._editshift.isEnabled(), True)

        # And check the Qline edit has the feature name populated
        self.assertEquals(self.gazetteer_plugin._currNameLabel.text(), "Geom_test")

    def test_B_move_feature_and_discard(self):
        """
        Move a feature and then abort the changes
        """

        # Create a new feature that we will then edit
        self.init_feature("Geom_test")

        # zoom to test location
        self.zoom_to_test_area(
            174.55264656290535,
            -41.55387872892347,
            174.5714208819715,
            -41.570869649805445,
        )

        # Test the feature is where expected prior to the move
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature refpt")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[0]
        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.55556, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.55556, places=3)

        # "to" "from" references for the move
        self.widget = iface.mapCanvas().viewport()
        from_x = 174.55556
        from_y = -41.55556
        to_x = 174.566666
        to_y = -41.566666

        # Enable the move tool
        self.gazetteer_plugin._editshift.trigger()
        QTest.qWait(500)
        self.assertEquals(self.gazetteer_plugin._editshift.isEnabled(), True)

        # Move the point
        self.move_point(from_x, from_y, to_x, to_y)
        QTest.qWait(500)

        # Test the feature has been moved - QGIS Layer
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature refpt")[0]
        iter = layer.getFeatures()
        feature = next(iter)

        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.56666, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.56666, places=3)
        # Also prove the gaz feat layer has a point associated to it.
        self.assertEqual(layer.featureCount(), 1)

        # Cancel Edits
        self.gazetteer_plugin._editcancel.trigger()

        QTest.qWait(500)

        # Assure the point has been moved back
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature refpt")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[0]
        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.55556, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.55556, places=3)

    def test_C_move_feature_and_save(self):
        """
        Move a feature and save its position to the DB
        """

        # Create a new feature we will then edit
        self.init_feature("Geom_test")

        # zoom to test location
        self.zoom_to_test_area(
            174.55264656290535,
            -41.55387872892347,
            174.5714208819715,
            -41.570869649805445,
        )

        # Test the feature is where expected
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature refpt")[0]
        iter = layer.getFeatures()
        feature = next(iter)

        feat_id = feature.attributes()[0]
        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.55556, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.55556, places=3)

        # Check the point was inserted to the database as expect
        db_feature_record = self.data_handler.get_feature_by_id(feat_id)
        ewkt = db_feature_record[0][6]
        wkt = ewkt.split(";")[1]
        point = QgsGeometry.fromWkt(wkt).asPoint()
        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.55556, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.55556, places=3)

        # "to" "from" references for the move
        from_x = 174.55556
        from_y = -41.55556
        to_x = 174.566666
        to_y = -41.566666

        # Enable the move tool
        self.gazetteer_plugin._editshift.trigger()
        QTest.qWait(500)
        self.assertEquals(self.gazetteer_plugin._editshift.isEnabled(), True)

        # Move the point
        self.move_point(from_x, from_y, to_x, to_y)
        QTest.qWait(500)

        # Test the feature has been moved - QGIS Layer
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature refpt")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        self.assertAlmostEqual(feature.geometry().asPoint()[0], 174.56666, places=3)
        self.assertAlmostEqual(feature.geometry().asPoint()[1], -41.56666, places=3)

        # Save to DB
        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()

        QTest.qWait(1000)

        # Test the feature has been moved - Database
        db_feature_record = self.data_handler.get_feature_by_id(feat_id)
        ewkt = db_feature_record[0][6]
        wkt = ewkt.split(";")[1]
        point = QgsGeometry.fromWkt(wkt).asPoint()
        self.assertAlmostEqual(point[0], 174.56666, places=3)
        self.assertAlmostEqual(point[1], -41.56666, places=3)

    def test_D_add_new_point_cancel(self):
        """
        Add a new point and then cancel the workflow
        """

        # Create a new feature to test against
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature point")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # zoom to test location
        self.zoom_to_test_area(
            174.55264656290535,
            -41.55387872892347,
            174.5714208819715,
            -41.570869649805445,
        )

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Add new point
        x = 174.566666
        y = -41.566666

        self.click_point(x, y)

        new_point_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature point - Feature Attributes"
        ][0]

        # reject the new geom
        new_point_dlg.reject()

        # Ensure the layer does not have a geom
        self.assertEqual(layer.featureCount(), 0)

    def test_E_add_new_point_ok(self):
        """
        Add a new point and select okay when dlg pops up
        """

        # Create a new feature to test against
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature point")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()
        QTest.qWait(500)
        self.assertEquals(self.gazetteer_plugin._editshift.isEnabled(), True)

        # Add new point
        x = 174.566666
        y = -41.566666

        self.click_point(x, y)

        # Get reference to the new point dialog that pops-up
        new_point_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature point - Feature Attributes"
        ][0]

        # Reject the new geom
        new_point_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Clean up
        self.gazetteer_plugin._editcancel.trigger()

    def test_F_add_new_point_ok_save(self):
        """
        Add a new point and then ok on the dlg and dave to DB
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature point")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Add new point
        x = 174.566666
        y = -41.566666

        self.click_point(x, y)

        new_point_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature point - Feature Attributes"
        ][0]

        # accept the new geom
        new_point_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Save to DB
        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(500)

        # Get feat_id
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature point")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[1]

        # Test the feature has been save to the DB as expected - Database
        db_feature_record = self.data_handler.get_feature_geom_by_id(feat_id)
        ewkt = db_feature_record[0][3]
        wkt = ewkt.split(";")[1]
        multipoint = QgsGeometry.fromWkt(wkt).asMultiPoint()
        self.assertAlmostEqual(multipoint[0][0], 174.566666, places=3)
        self.assertAlmostEqual(multipoint[0][1], -41.566666, places=3)

    def test_G_add_new_point_and_move(self):
        """
        Once a new point has been added to a feature can we move it?
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature point")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Add new point
        x = 174.566666
        y = -41.566666

        self.click_point(x, y)

        new_point_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature point - Feature Attributes"
        ][0]

        # accept the new geom
        new_point_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Save edit
        QTimer.singleShot(500, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(1000)
        # "to" "from" references for the move
        self.widget = iface.mapCanvas().viewport()
        from_x = 174.55556
        from_y = -41.55556
        to_x = 174.566666
        to_y = -41.566666

        # Enable the move tool
        self.gazetteer_plugin._editshift.trigger()
        QTest.qWait(500)
        self.assertEquals(self.gazetteer_plugin._editshift.isEnabled(), True)

        # Move the point
        self.move_point(from_x, from_y, to_x, to_y)
        QTest.qWait(500)

        # Can we now move this point with the move tool?

        # zoom to test location
        self.zoom_to_test_area(
            174.55264656290535,
            -41.55387872892347,
            174.5714208819715,
            -41.570869649805445,
        )

        # "to" "from" references for the move
        self.widget = iface.mapCanvas().viewport()
        from_x = 174.566666
        from_y = -41.566666
        to_x = 174.566260
        to_y = -41.555540

        # Enable the move tool
        self.gazetteer_plugin._editshift.trigger()
        QTest.qWait(1000)
        self.assertEquals(self.gazetteer_plugin._editshift.isEnabled(), True)

        # Move the point
        self.move_point(from_x, from_y, to_x, to_y)
        QTest.qWait(600)

        # Test the feature has been moved - QGIS Layer
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature point")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[1]

        self.assertAlmostEqual(
            feature.geometry().asMultiPoint()[0][0], 174.566260, places=3
        )
        self.assertAlmostEqual(
            feature.geometry().asMultiPoint()[0][1], -41.555540, places=3
        )
        # Also prove the gaz feat layer has a point associated to it.
        self.assertEqual(layer.featureCount(), 1)

        # Save to DB
        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(500)

        # Test the feature has been moved - Database
        db_feature_record = self.data_handler.get_feature_geom_by_id(feat_id)
        ewkt = db_feature_record[0][3]
        wkt = ewkt.split(";")[1]
        multipoint = QgsGeometry.fromWkt(wkt).asMultiPoint()
        self.assertAlmostEqual(multipoint[0][0], 174.566260, places=3)
        self.assertAlmostEqual(multipoint[0][1], -41.555540, places=3)

    def test_H_add_new_line_cancel(self):
        """
        Add a new point and then cancel the workflow
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature line")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # zoom to test location
        self.zoom_to_test_area(
            174.55264656290535,
            -41.55387872892347,
            174.5714208819715,
            -41.570869649805445,
        )

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Drawline
        self.click_point(174.5508, -41.5584)
        self.click_point(174.5619, -41.5587)
        self.click_point(174.5748, -41.5661)
        self.click_point(174.5778, -41.5686, Qt.RightButton)

        # Get reference to Feature Attributes Dlg
        new_line_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature line - Feature Attributes"
        ][0]

        # reject the new geom
        new_line_dlg.reject()

        # Ensure the layer does not have a geom
        self.assertEqual(layer.featureCount(), 0)

    def test_I_add_new_line_ok(self):
        """
        Add a new line and then cancel the workflow
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature line")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Drawline
        self.click_point(174.5508, -41.5584)
        self.click_point(174.5619, -41.5587)
        self.click_point(174.5748, -41.5661)
        self.click_point(174.5778, -41.5686, Qt.RightButton)

        # Get reference to Feature Attributes Dlg
        new_line_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature line - Feature Attributes"
        ][0]

        # reject the new geom
        new_line_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Clean up
        self.gazetteer_plugin._editcancel.trigger()

    def test_J_add_new_line_ok_save(self):
        """
        Add a new line geom to layer and save to DB
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature line")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Drawline
        self.click_point(174.5508, -41.5584)
        self.click_point(174.5619, -41.5587)
        self.click_point(174.5748, -41.5661)
        self.click_point(174.5778, -41.5686, Qt.RightButton)

        # Get reference to Feature Attributes Dlg
        new_line_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature line - Feature Attributes"
        ][0]

        # accept the new geom
        new_line_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Save to DB
        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(500)

        # Get feat_id
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature line")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[1]

        # Test the new line has been added to the DB
        db_feature_record = self.data_handler.get_feature_geom_by_id(feat_id)
        ewkt = db_feature_record[0][3]
        wkt = ewkt.split(";")[1]
        multiLineString = QgsGeometry.fromWkt(wkt)
        vertices = multiLineString.vertices()

        v1 = next(vertices)
        self.assertAlmostEqual(v1.x(), 174.5508, places=3)
        self.assertAlmostEqual(v1.y(), -41.5584, places=3)

        v2 = next(vertices)
        self.assertAlmostEqual(v2.x(), 174.5619, places=3)
        self.assertAlmostEqual(v2.y(), -41.5587, places=3)

        v3 = next(vertices)
        self.assertAlmostEqual(v3.x(), 174.5748, places=3)
        self.assertAlmostEqual(v3.y(), -41.5661, places=3)

    def test_K_add_new_line_and_move(self):
        """
        Add a new line geom to layer and then edit a vertice
        to test vertice functionality
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature line")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # zoom to test location
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.54455565, -41.55007600, 174.57627203, -41.57580511
        )

        canvas.setExtent(zoom_rectangle)
        canvas.refresh()
        QTest.qWait(500)

        # Drawline
        self.click_point(174.5508, -41.5584)
        self.click_point(174.5619, -41.5587)
        self.click_point(174.5748, -41.5661)
        self.click_point(174.5778, -41.5686, Qt.RightButton)

        # Get reference to Feature Attributes Dlg
        new_line_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature line - Feature Attributes"
        ][0]

        # accept the new geom
        new_line_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Get feat_id
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature line")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[1]

        # Save to DB
        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(500)

        # Enable node editing
        self.gazetteer_plugin._editnodes.trigger()
        QTest.qWait(500)
        self.assertEquals(self.gazetteer_plugin._editnodes.isEnabled(), True)

        # "to" "from" references for the move
        self.widget = iface.mapCanvas().viewport()
        from_x = 174.5619
        from_y = -41.5587
        to_x = 174.5566
        to_y = -41.5719

        # Move the node
        self.move_point(from_x, from_y, to_x, to_y)
        QTest.qWait(500)

        # Save to DB
        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(500)

        # Get feat_id
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature line")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[1]

        # Test the new line has been added to the DB
        db_feature_record = self.data_handler.get_feature_geom_by_id(feat_id)
        ewkt = db_feature_record[0][3]
        wkt = ewkt.split(";")[1]
        multiLineString = QgsGeometry.fromWkt(wkt)
        vertices = multiLineString.vertices()

        v1 = next(vertices)
        self.assertAlmostEqual(v1.x(), 174.5508, places=3)
        self.assertAlmostEqual(v1.y(), -41.5584, places=3)

        v2 = next(vertices)
        self.assertAlmostEqual(v2.x(), 174.5566, places=3)
        self.assertAlmostEqual(v2.y(), -41.5719, places=3)

        v3 = next(vertices)
        self.assertAlmostEqual(v3.x(), 174.5748, places=3)
        self.assertAlmostEqual(v3.y(), -41.5661, places=3)

    def test_L_add_new_poly_cancel(self):
        """
        Add a new polygpn and then cancel the workflow
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature poly")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # zoom to test location
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.54455565, -41.55007600, 174.57627203, -41.57580511
        )

        canvas.setExtent(zoom_rectangle)
        canvas.refresh()
        QTest.qWait(500)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Draw Poly
        self.click_point(174.5508, -41.5584)
        self.click_point(174.5619, -41.5587)
        self.click_point(174.5748, -41.5661)
        self.click_point(174.5566, -41.5719)
        self.click_point(174.5778, -41.5686, Qt.RightButton)

        QTest.qWait(500)

        # Get reference to Feature Attributes Dlg
        new_poly_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature poly - Feature Attributes"
        ][0]

        # reject the new geom
        new_poly_dlg.reject()

        # Ensure the layer does not have a geom
        self.assertEqual(layer.featureCount(), 0)

    def test_M_add_new_poly_ok(self):
        """
        Add a new poly and then cancel the workflow
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature poly")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # zoom to test location
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.54455565, -41.55007600, 174.57627203, -41.57580511
        )

        canvas.setExtent(zoom_rectangle)
        canvas.refresh()
        QTest.qWait(500)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Draw Poly
        self.click_point(174.5508, -41.5584)
        self.click_point(174.5619, -41.5587)
        self.click_point(174.5748, -41.5661)
        self.click_point(174.5566, -41.5719)
        self.click_point(174.5778, -41.5686, Qt.RightButton)

        QTest.qWait(500)

        # Get reference to Feature Attributes Dlg
        new_poly_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature poly - Feature Attributes"
        ][0]

        # reject the new geom
        new_poly_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Clean up
        self.gazetteer_plugin._editcancel.trigger()

    def test_N_add_new_poly_ok_save(self):
        """
        Add a new poly geom to feature and save to DB
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature poly")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # zoom to test location
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.54455565, -41.55007600, 174.57627203, -41.57580511
        )

        canvas.setExtent(zoom_rectangle)
        canvas.refresh()
        QTest.qWait(500)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Draw Poly
        self.click_point(174.5508, -41.5584)
        self.click_point(174.5619, -41.5587)
        self.click_point(174.5748, -41.5661)
        self.click_point(174.5566, -41.5719)
        self.click_point(174.5778, -41.5686, Qt.RightButton)

        QTest.qWait(500)

        # Get reference to Feature Attributes Dlg
        new_poly_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature poly - Feature Attributes"
        ][0]

        # accept the new geom
        new_poly_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Save to DB
        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(500)

        # Get feat_id
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature poly")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[1]

        # Test the new poly has been added to the DB
        db_feature_record = self.data_handler.get_feature_geom_by_id(feat_id)
        ewkt = db_feature_record[0][3]
        wkt = ewkt.split(";")[1]
        multiLineString = QgsGeometry.fromWkt(wkt)
        vertices = multiLineString.vertices()

        v1 = next(vertices)
        self.assertAlmostEqual(v1.x(), 174.5508, places=3)
        self.assertAlmostEqual(v1.y(), -41.5584, places=3)

        v2 = next(vertices)
        self.assertAlmostEqual(v2.x(), 174.5619, places=3)
        self.assertAlmostEqual(v2.y(), -41.5587, places=3)

        v3 = next(vertices)
        self.assertAlmostEqual(v3.x(), 174.5748, places=3)
        self.assertAlmostEqual(v3.y(), -41.5661, places=3)

        v4 = next(vertices)
        self.assertAlmostEqual(v4.x(), 174.5566, places=3)
        self.assertAlmostEqual(v4.y(), -41.5719, places=3)

    def test_O_add_new_poly_and_move(self):
        """
        Add a new poly geom to feature and then edit a vertice
        to test the vertice move tool
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature poly")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # zoom to test location
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.54455565, -41.55007600, 174.57627203, -41.57580511
        )

        canvas.setExtent(zoom_rectangle)
        canvas.refresh()
        QTest.qWait(500)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Draw Poly
        self.click_point(174.5508, -41.5584)
        self.click_point(174.5619, -41.5587)
        self.click_point(174.5748, -41.5661)
        self.click_point(174.5566, -41.5719)
        self.click_point(174.5778, -41.5686, Qt.RightButton)

        QTest.qWait(500)

        # Get reference to Feature Attributes Dlg
        new_poly_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature poly - Feature Attributes"
        ][0]

        # accept the new geom
        new_poly_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Get feat_id
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature poly")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[1]

        # Save to DB
        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(500)

        # Enable node editing
        self.gazetteer_plugin._editnodes.trigger()
        QTest.qWait(500)
        self.assertEquals(self.gazetteer_plugin._editnodes.isEnabled(), True)

        # "to" "from" references for the move
        self.widget = iface.mapCanvas().viewport()
        from_x = 174.5566
        from_y = -41.5719
        to_x = 174.5461
        to_y = -41.5665

        # Move the node
        self.move_point(from_x, from_y, to_x, to_y)
        QTest.qWait(500)

        # Save to DB
        QTimer.singleShot(1000, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(500)

        # Get feat_id
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature poly")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        feat_id = feature.attributes()[1]

        # Test the new line has been added to the DB
        db_feature_record = self.data_handler.get_feature_geom_by_id(
            feat_id
        )  ### WHAT should be geom_id
        ewkt = db_feature_record[0][3]
        wkt = ewkt.split(";")[1]
        multiLineString = QgsGeometry.fromWkt(wkt)
        vertices = multiLineString.vertices()

        v1 = next(vertices)
        self.assertAlmostEqual(v1.x(), 174.5508, places=3)
        self.assertAlmostEqual(v1.y(), -41.5584, places=3)

        v2 = next(vertices)
        self.assertAlmostEqual(v2.x(), 174.5619, places=3)
        self.assertAlmostEqual(v2.y(), -41.5587, places=3)

        v3 = next(vertices)
        self.assertAlmostEqual(v3.x(), 174.5748, places=3)
        self.assertAlmostEqual(v3.y(), -41.5661, places=3)

        v4 = next(vertices)
        self.assertAlmostEqual(v4.x(), 174.5461, places=3)
        self.assertAlmostEqual(v4.y(), -41.5665, places=3)

    def test_P_remove_poly_from_feature(self):
        """
        Add a new poly geom to layer and then edit a vertice
        to test vertice functionality
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Select layer in ToC
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature poly")[0]
        iface.layerTreeView().setCurrentLayer(layer)

        # zoom to test location
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.54455565, -41.55007600, 174.57627203, -41.57580511
        )

        canvas.setExtent(zoom_rectangle)
        canvas.refresh()
        QTest.qWait(500)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # Draw Poly
        self.click_point(174.5508, -41.5584)
        self.click_point(174.5619, -41.5587)
        self.click_point(174.5748, -41.5661)
        self.click_point(174.5566, -41.5719)
        self.click_point(174.5778, -41.5686, Qt.RightButton)

        QTest.qWait(500)

        # Get reference to Feature Attributes Dlg
        new_poly_dlg = [
            dialog
            for dialog in iface.mainWindow().findChildren(QDialog)
            if dialog.windowTitle() == "Gazetteer feature poly - Feature Attributes"
        ][0]

        # Accept the new geom
        new_poly_dlg.accept()

        # Ensure the layer has a feature
        self.assertEqual(layer.featureCount(), 1)

        # Save to DB
        QTimer.singleShot(500, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(1000)

        # Get feat_id
        layer = QgsProject.instance().mapLayersByName("Gazetteer feature poly")[0]
        iter = layer.getFeatures()
        feature = next(iter)
        geom_id = feature.attributes()[0]
        feat_id = feature.attributes()[1]

        # Check a geom was added against this ID
        db_feature_record = self.data_handler.get_feature_geom_by_id(feat_id)
        self.assertEqual(len(db_feature_record), 1)

        # now delete geom
        layer.select(geom_id)
        QTimer.singleShot(500, self.activeModalWindowOk)
        self.gazetteer_plugin._delselaction.trigger()
        QTest.qWait(1000)

        # this feat has no geoms. Therefore the one we add and
        # have now deleted no longer exists in the DB
        db_feature_record = self.data_handler.get_feature_geom_by_id(feat_id)
        self.assertEqual(len(db_feature_record), 0)

    def test_Q_add_point_to_feature(self):
        """
        Add a layer not related to Plugin and select features
        from this layer to add a features geometry
        """

        # Create a new feature to test adding a geom to
        self.init_feature("Geom_test")

        # Get feat_id
        feat_layer = QgsProject.instance().mapLayersByName("Gazetteer feature refpt")[0]
        iter = feat_layer.getFeatures()
        feature = next(iter)
        feat_id = feature.id()

        # Confirm there are no geoms associated at this stage
        db_feature_record = self.data_handler.get_feature_geom_by_id(feat_id)
        self.assertEqual(len(db_feature_record), 0)

        # zoom to test location
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.54455565, -41.55007600, 174.57627203, -41.57580511
        )

        canvas.setExtent(zoom_rectangle)
        canvas.refresh()
        QTest.qWait(500)

        # Trigger the new geom tool
        self.gazetteer_plugin._editnew.trigger()

        # create layer with points that will be then added to a gaz feature

        # create the temp layer
        temp_layer = QgsVectorLayer(
            "Point?crs=epsg:4326&field=id:integer", "temporary_points", "memory"
        )
        pr = temp_layer.dataProvider()

        # add fields
        pr.addAttributes(
            [QgsField("id", QVariant.Int), QgsField("value", QVariant.String)]
        )
        temp_layer.updateFields()  # tell the vector layer to fetch changes from the provider

        # add features
        fet_1 = QgsFeature()
        fet_1.setGeometry(QgsGeometry.fromPointXY(QgsPointXY(174.5619, -41.5587)))
        fet_1.setAttributes([1, "test_geom_1"])

        fet_2 = QgsFeature()
        fet_2.setGeometry(QgsGeometry.fromPointXY(QgsPointXY(174.5748, -41.5661)))
        fet_2.setAttributes([2, "test_geom_2"])

        fet_3 = QgsFeature()
        fet_3.setGeometry(QgsGeometry.fromPointXY(QgsPointXY(174.5508, -41.5584)))
        fet_3.setAttributes([3, "test_geom_3"])

        pr.addFeatures([fet_1, fet_2, fet_3])

        # update layer's extent when new features have been added
        # because change of extent in provider is not propagated to the layer
        temp_layer.updateExtents()

        QgsProject.instance().addMapLayer(temp_layer, False)

        root = QgsProject.instance().layerTreeRoot()
        root.insertChildNode(0, QgsLayerTreeLayer(temp_layer))

        # Addd selected geom to feature
        temp_layer.select(2)
        temp_layer.select(3)

        QTest.qWait(500)

        QTimer.singleShot(500, self.activeModalWindowOk)
        self.gazetteer_plugin._addselaction.trigger()
        QTest.qWait(1000)

        # Save to DB
        QTimer.singleShot(500, self.activeModalWindowAccept)
        self.gazetteer_plugin._editsave.trigger()
        QTest.qWait(1000)

        # The selected geoms should now have been added
        db_feature_record = self.data_handler.get_feature_geom_by_id(feat_id)
        self.assertEqual(len(db_feature_record), 2)

        # clean up
        QgsProject.instance().removeMapLayers([temp_layer.id()])
