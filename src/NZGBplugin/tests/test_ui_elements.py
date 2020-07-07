import unittest


from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qgis.core import QgsProject
from qgis.utils import plugins, reloadPlugin

from utils.data_handler import TestDataHandler


class TestUi(unittest.TestCase):
    """
    Just test UI elements. No data requests
    """

    @classmethod
    def setUpClass(cls):

        # insert required sys_codes to allow new feature creation
        cls.data_handler = TestDataHandler()
        cls.data_handler.insert_sys_codes()

        # when running in QGIS via the script assistant
        # Plugin but setting a voluntary_wait > 0 the tester
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

        # # removed required sys_codes when finished
        # cls.data_handler.delete_sys_codes() # TEMP COMMENTED OUT

        # Remove all layers
        QgsProject.instance().removeAllMapLayers()

        # And groups
        root = QgsProject.instance().layerTreeRoot()
        for group in [child for child in root.children() if child.nodeType() == 0]:
            root.removeChildNode(group)

    def test_A_layers_load_on_start(self):
        """
        Ensure on start the expected test layers have loaded
        """

        expected_loaded_layers = [
            "Gazetteer feature line",
            "Gazetteer feature point",
            "Gazetteer feature poly",
            "Gazetteer feature refpt",
            "Gazetteer search line",
            "Gazetteer search point",
            "Gazetteer search poly",
            "Gazetteer search refpt",
        ]

        layers = [layer.name() for layer in QgsProject.instance().mapLayers().values()]
        assert layers == expected_loaded_layers

    def test_B_tools_enabled_on_start(self):
        """
        Test starting the plugin enables the correct tools
        while leaving the rest diabled
        """

        self.assertTrue(self.gazetteer_plugin._newfeat.isEnabled())

    def test_C_tools_disabled_on_start(self):
        self.assertFalse(self.gazetteer_plugin._ptraction.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editshift.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editnodes.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editnew.isEnabled())
        self.assertFalse(self.gazetteer_plugin._addselaction.isEnabled())
        self.assertFalse(self.gazetteer_plugin._delselaction.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editsave.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editcancel.isEnabled())

    def test_D_editordockwidget_is_docked(self):
        """
        The the editor dock widget is present and docked
        """

        self.assertFalse(self.gazetteer_plugin._editorDock.isFloating())

    def test_E_click_tab_text(self):
        """
        The Help tab is present
        """

        self.assertEqual(
            self.gazetteer_plugin._editor.findChildren(QTabBar)[1].tabText(0), "Search"
        )
        self.assertEqual(
            self.gazetteer_plugin._editor.findChildren(QTabBar)[1].tabText(1), "Help"
        )

    def test_F_click_tab_search(self):
        """
        The Search tab is present
        """

        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].tabText(
            self.gazetteer_plugin._editor.findChildren(QTabBar)[1].currentIndex()
        ) == "Search"
