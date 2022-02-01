import unittest
import random
import string

from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qgis.core import QgsProject, QgsPointXY, QgsRectangle
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
        # With clean plugin state

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

    @staticmethod
    def get_random_string(length):
        chars = string.ascii_lowercase
        return "".join(random.choice(chars) for i in range(length))

    def test_A_search_no_results(self):
        """
        Put a nonsense search query string and
        ensure there are no results returned
        """

        # Move search tab to the front
        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].setCurrentIndex(0)
        search_widget = self.gazetteer_plugin._editor._searchWindow.widget()
        search_widget.tabs.setCurrentWidget(search_widget.tabSearch)

        # Get reference to the tableview
        search_table = search_widget.uSearchResults

        # Set the search Text
        search_widget.uSearchText.setText("dassdasdsa")

        # Click the Search Button
        search_widget.uSearchButton.animateClick()
        QTest.qWait(500)

        # Assert no results found
        search_status = search_widget.uSearchStatus.text()
        self.assertEqual(search_status, "0 match found")
        self.assertEqual(search_table.rowCount(), 0)

    def test_B_get_unique_search_results(self):
        """ """

        # Move search tab to the front
        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].setCurrentIndex(0)
        search_widget = self.gazetteer_plugin._editor._searchWindow.widget()
        search_widget.tabs.setCurrentWidget(search_widget.tabSearch)

        # Using random string to ensure unique place name
        # when tests are ran multiple times
        place_name = self.get_random_string(12)
        self.init_feature(place_name)

        # Search should eventually update the Gazetteer search refpt layer
        layer = QgsProject.instance().mapLayersByName("Gazetteer search refpt")[0]
        iface.layerTreeView().setCurrentLayer(layer)
        self.assertEqual(layer.featureCount(), 0)

        # Move search tab to the front
        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].setCurrentIndex(0)
        search_widget = self.gazetteer_plugin._editor._searchWindow.widget()

        # Get reference to the tableview
        search_table = search_widget.uSearchResults

        # Set the search Text
        search_widget.uSearchText.setText(place_name)

        # Click the Search Button
        search_widget.uSearchButton.animateClick()
        QTest.qWait(500)

        # Assert results found
        search_status = search_widget.uSearchStatus.text()
        self.assertEqual(
            search_status,
            "1 matches found. Click name to open, Shift+Click to open in new window",
        )
        self.assertEqual(search_table.rowCount(), 1)

        # Validate the search layer
        layer = QgsProject.instance().mapLayersByName("Gazetteer search refpt")[0]
        iface.layerTreeView().setCurrentLayer(layer)
        self.assertEqual(layer.featureCount(), 1)
        iter = layer.getFeatures()
        feature = next(iter)
        attributes = feature.attributes()
        self.assertEqual(place_name, attributes[1])

    def test_C_add_to_favourtie(self):
        """
        Add a feature to favourtie and ensure it is in the "favourties" tables
        """

        # Move search tab to the front
        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].setCurrentIndex(0)
        search_widget = self.gazetteer_plugin._editor._searchWindow.widget()
        search_widget.tabs.setCurrentWidget(search_widget.tabSearch)

        place_name = self.get_random_string(12)
        self.init_feature(place_name)

        # Get reference to the tableview
        search_table = search_widget.uSearchResults

        # Get reference to the favourties tableview
        favourties_table = search_widget.uFavourites

        # Set the search Text
        search_widget.uSearchText.setText(place_name)

        # Click the Search Button
        search_widget.uSearchButton.animateClick()
        QTest.qWait(500)

        # Click on the first record
        name_id = search_table.itemAt(0)["name_id"]
        search_widget.nameSelected.emit(name_id, 0)

        # Get reference to the webview
        web_view = [
            dock_widget.widget()
            for dock_widget in self.gazetteer_plugin._editor.findChildren(QDockWidget)
            if dock_widget.__class__.__name__ == "NameWebDock"
        ][0]
        html_doc = web_view.page().mainFrame().documentElement().document()

        # Click on fav button
        html_doc.findFirst("img").evaluateJavaScript("this.click()")

        # Bring Favourites tab to front
        search_widget.tabs.setCurrentWidget(search_widget.tabFavourites)

        # Get row count
        number_rows = favourties_table.model().count()

        # Validate table data
        data = favourties_table.model().getItems(list(range(0, number_rows)))
        names = [d["name"] for d in data]
        self.assertTrue(place_name in names)

    def test_D_remove_from_favourtie(self):
        """
        Remove item from favourites and ensure the favourites table updates
        """

        # Move search tab to the front
        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].setCurrentIndex(0)
        search_widget = self.gazetteer_plugin._editor._searchWindow.widget()
        search_widget.tabs.setCurrentWidget(search_widget.tabSearch)

        place_name = self.get_random_string(12)
        self.init_feature(place_name)

        # Get reference to the tableview
        search_table = search_widget.uSearchResults

        # Get reference to the favourties tableview
        favourties_table = search_widget.uFavourites

        # Set the search Text
        search_widget.uSearchText.setText(place_name)

        # Click the Search Button
        search_widget.uSearchButton.animateClick()
        QTest.qWait(500)

        # Click on the first record
        name_id = search_table.itemAt(0)["name_id"]
        search_widget.nameSelected.emit(name_id, 0)

        # Get reference to the webview
        web_view = [
            dock_widget.widget()
            for dock_widget in self.gazetteer_plugin._editor.findChildren(QDockWidget)
            if dock_widget.__class__.__name__ == "NameWebDock"
        ][0]
        html_doc = web_view.page().mainFrame().documentElement().document()

        # Click on fav button making it a fav
        html_doc.findFirst("img").evaluateJavaScript("this.click()")

        # bring Favourites tab to front
        search_widget.tabs.setCurrentWidget(search_widget.tabFavourites)

        # Make sure it is a fav

        # Get row count
        number_rows = favourties_table.model().count()

        # Get table data
        data = favourties_table.model().getItems(list(range(0, number_rows)))
        names = [d["name"] for d in data]
        self.assertTrue(place_name in names)

        # Now attempt to remove it from favourites

        # Get relationship between name_id and name text
        number_rows = favourties_table.model().count()
        favourites = favourties_table.model().getItems(list(range(0, number_rows)))
        name_ids = {}
        for favourite in favourites:
            name_ids[favourite["name"]] = favourite["name_id"]
        name_id = name_ids[place_name]

        # Click on the favourites record to navigate to the record
        search_widget.nameSelected.emit(name_id, 0)

        # Now uncheck the favourites star

        # Get reference to the current webview
        web_view = [
            dock_widget.widget()
            for dock_widget in self.gazetteer_plugin._editor.findChildren(QDockWidget)
            if dock_widget.__class__.__name__ == "NameWebDock"
        ][0]
        html_doc = web_view.page().mainFrame().documentElement().document()
        html_doc.findFirst("img").evaluateJavaScript("this.click()")

        # Navigate back to the favourites tab to ensure it is no longer a favourite
        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].setCurrentIndex(0)
        search_widget = self.gazetteer_plugin._editor._searchWindow.widget()
        search_widget.tabs.setCurrentWidget(search_widget.tabFavourites)

        # Get row count
        number_rows = favourties_table.model().count()

        # Get table data
        data = favourties_table.model().getItems(list(range(0, number_rows)))
        names = [d["name"] for d in data]

        # Make sure the record is no longer there
        self.assertTrue(place_name not in names)

        # Move search tab to the front
        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].setCurrentIndex(0)
        search_widget = self.gazetteer_plugin._editor._searchWindow.widget()
        search_widget.tabs.setCurrentWidget(search_widget.tabSearch)

        place_name = self.get_random_string(12)
        self.init_feature(place_name)

        # Get reference to the search tableview
        search_table = search_widget.uSearchResults

        # Set the search Text
        search_widget.uSearchText.setText(place_name)

        # Click the Search Button
        search_widget.uSearchButton.animateClick()
        QTest.qWait(500)

        # Click on the favourite record
        name_id = search_table.itemAt(0)["name_id"]
        search_widget.nameSelected.emit(name_id, 0)

        # Get reference to the webview
        web_view = [
            dock_widget.widget()
            for dock_widget in self.gazetteer_plugin._editor.findChildren(QDockWidget)
            if dock_widget.__class__.__name__ == "NameWebDock"
        ][0]
        html_doc = web_view.page().mainFrame().documentElement().document()

        # Click on fav button
        html_doc.findFirst("img").evaluateJavaScript("this.click()")

        # bring Favourites tab to front
        search_widget.tabs.setCurrentWidget(search_widget.tabFavourites)

        # Get row count
        number_rows = favourties_table.model().count()

        # validate table data - record no longer a favourite
        data = favourties_table.model().getItems(list(range(0, number_rows)))
        names = [d["name"] for d in data]
        self.assertTrue(place_name in names)

    def test_E_search_in_map_area(self):

        # Create a feature for the test
        place_name = self.get_random_string(12)
        self.init_feature(place_name)
        QTest.qWait(500)

        # Move search tab to the front
        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].setCurrentIndex(0)
        search_widget = self.gazetteer_plugin._editor._searchWindow.widget()
        search_widget.tabs.setCurrentWidget(search_widget.tabSearch)

        # Get reference to the tableview
        search_table = search_widget.uSearchResults

        # Set the search Text
        search_widget.uSearchText.setText(place_name)

        # Click the Search Button
        search_widget.uSearchButton.animateClick()
        QTest.qWait(500)

        # Assert results are found
        search_status = search_widget.uSearchStatus.text()
        self.assertEqual(
            search_status,
            "1 matches found. Click name to open, Shift+Click to open in new window",
        )
        self.assertEqual(search_table.rowCount(), 1)

        # Navigate away from the feature
        # to prove "Limit search to map area" button works
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.99782688, -40.88249287, 175.11391715, -40.96439681
        )

        canvas.setExtent(zoom_rectangle)
        canvas.refresh()
        QTest.qWait(500)

        # Click the advanced button
        search_widget.uSearchMapExtent.setChecked(False)
        search_widget.uToggleAdvanced.animateClick()
        QTest.qWait(500)

        # Click the "Limit search to map area" button
        search_widget.uSearchMapExtent.animateClick()
        QTest.qWait(500)
        self.assertTrue(search_widget.uSearchMapExtent.isChecked())
        QTest.qWait(500)

        # Set the search Text
        search_widget.uSearchText.setText(place_name)
        QTest.qWait(500)

        # Click the Search Button
        search_widget.uSearchButton.animateClick()
        QTest.qWait(500)

        # Assert no results are found
        search_status = search_widget.uSearchStatus.text()
        self.assertEqual(search_status, "0 match found")
        self.assertEqual(search_table.rowCount(), 0)

        # While we are here test zooming back to the area the feature is located
        # with uSearchMapExtent enabled does return results

        # zoom to test location where feats are
        canvas = iface.mapCanvas()
        zoom_rectangle = QgsRectangle(
            174.55264656290535,
            -41.55387872892347,
            174.5714208819715,
            -41.570869649805445,
        )
        canvas.setExtent(zoom_rectangle)
        canvas.refresh()
        search_widget.uSearchMapExtent.setChecked(False)

        # Run the search test again

        # Set the search Text
        search_widget.uSearchText.setText(place_name)
        QTest.qWait(500)

        # Click the Search Button
        search_widget.uSearchButton.animateClick()
        QTest.qWait(500)

        # Assert results are found
        search_status = search_widget.uSearchStatus.text()
        self.assertEqual(
            search_status,
            "1 matches found. Click name to open, Shift+Click to open in new window",
        )
        self.assertEqual(search_table.rowCount(), 1)

        search_widget.uToggleAdvanced.animateClick()
