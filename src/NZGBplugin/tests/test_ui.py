import unittest


from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qgis.core import QgsProject
from qgis.utils import plugins


class TestUi(unittest.TestCase):
    """
    Just test UI elements. No data requests
    """

    def setUp(cls):
        """
        Runs before each test.
        """

        if not plugins.get("NZGBplugin"):
            pass
        else:
            cls.gazetteer_plugin = plugins.get("NZGBplugin")
            cls.gazetteer_plugin._runaction.trigger()

    def test_layers_load_on_start(self):
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

    def test_tools_enabled_on_start(self):
        self.assertTrue(self.gazetteer_plugin._newfeat.isEnabled())

    def test_tools_disabled_on_start(self):
        self.assertFalse(self.gazetteer_plugin._ptraction.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editshift.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editnodes.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editnew.isEnabled())
        self.assertFalse(self.gazetteer_plugin._addselaction.isEnabled())
        self.assertFalse(self.gazetteer_plugin._delselaction.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editsave.isEnabled())
        self.assertFalse(self.gazetteer_plugin._editcancel.isEnabled())

    def test_editordockwidget_is_docked(self):
        self.assertFalse(self.gazetteer_plugin._editorDock.isFloating())

    def test_click_tab_text(self):
        assert (
            self.gazetteer_plugin._editor.findChildren(QTabBar)[1].tabText(0)
            == "Search"
        )
        assert (
            self.gazetteer_plugin._editor.findChildren(QTabBar)[1].tabText(1) == "Help"
        )

    def test_click_search(self):
        self.gazetteer_plugin._editor.findChildren(QTabBar)[1].tabText(
            self.gazetteer_plugin._editor.findChildren(QTabBar)[1].currentIndex()
        ) == "Search"


def suite():
    suite = unittest.TestSuite()
    suite.addTests(unittest.makeSuite(UnitLevel, "test"))
    return suite


def run_tests():
    unittest.TextTestRunner(verbosity=3).run(suite())
