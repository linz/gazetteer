import configparser
import os.path
import unittest


class TestMetadata(unittest.TestCase):
    """
    Test metadata.txt conforms to minimum requirements
    """

    def test_metadata(self):
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


def suite():
    suite = unittest.TestSuite()
    suite.addTests(unittest.makeSuite(UnitLevel, "test"))
    return suite


def run_tests():
    unittest.TextTestRunner(verbosity=3).run(suite())
