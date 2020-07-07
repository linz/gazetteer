import unittest
import os.path
import configparser
from qgis.utils import plugins, reloadPlugin

from utils.data_handler import TestDataHandler


class TestMetadata(unittest.TestCase):
    """
    Test metadata.txt conforms to minimum requirements
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

        # removed required sys_codes when finished
        cls.data_handler.delete_sys_codes()

    def test_A_metadata(self):
        """
        minimum metadata.txt requirments as per
        https://docs.qgis.org/3.10/en/docs/pyqgis_developer_cookbook/plugins/plugins.html#plugin-metadata-table
        """

        required_metadata = [
            "name",
            "qgisMinimumVersion",
            "about",
            "version",
            "description",
            "version",
            "email",
            "author",
        ]

        metadata_file = os.path.dirname(__file__) + "/../metadata.txt"

        config = configparser.ConfigParser()
        config.read(metadata_file)

        for required in required_metadata:
            self.assertIn(required, config["general"])
