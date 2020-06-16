import unittest


from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qgis.core import QgsProject, QgsPointXY
from qgis.utils import plugins, iface
from PyQt5.QtTest import QTest
from qgis.gui import QgsMapTool
from PyQt5.QtWebKitWidgets import QWebPage

from utils.database import Database
from utils.test_data_handler import TestDataHandler


class TestUi(unittest.TestCase):
    """
    Just test UI elements. No data requests
    """

    @classmethod
    def setUpClass(cls):
        """
        Runs at TestCase init.
        """

        # insert required sys_codes to allow new feature creation
        cls.test_data_handler = TestDataHandler()
        cls.test_data_handler.insert_sys_codes()

        # If tests are run directly in QGIS set >0
        # Get a better visual on running tests
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
        # removed required sys_codes to allow new feature creation

        # cls.test_data_handler.delete_sys_codes()

        # TODO// delete all name feature records? how
        # gazetteer.gaz_createnewfeature inserts into gazetteer.name
        #

    def setUp(cls):
        """
        Runs before each test.
        """
        pass
        # todo// ensure docket widget is on the correct tab

    def tearDown(cls):
        """
        Runs after each test
        """
        iface.dlg_create_new.uFeatName.setText("")

    def trigger_new_feature_dlg(self, x=174.76318, y=-41.28338):
        """
        
        """
        widget = iface.mapCanvas().viewport()
        canvas_point = QgsMapTool(iface.mapCanvas()).toCanvasCoordinates
        QTest.mouseClick(
            widget, Qt.LeftButton, pos=canvas_point(QgsPointXY(x, y)), delay=0
        )
        QTest.qWait(1000)

    def close_new_feature_dlg(self):
        QTest.qWait(1000)
        iface.dlg_create_new.close()

    def test_new_feature_dlg(self):
        """
        Test new feature dialog opens on map canvas click
        """

        # Mimic user selecting new feature tool
        self.gazetteer_plugin._newfeat.trigger()
        self.trigger_new_feature_dlg()
        self.assertEquals(iface.dlg_create_new.uFeatName.text(), "")
        self.close_new_feature_dlg()

    def test_new_feature_dlg(self):
        """
        Test new feature dialog opens on map canvas click
        """

        # Mimic user selecting new feature tool
        self.gazetteer_plugin._newfeat.trigger()
        self.trigger_new_feature_dlg()
        self.assertEquals(iface.dlg_create_new.uFeatName.text(), "")
        self.close_new_feature_dlg()

    def test_new_feature_dlg_name_missing(self):
        """
        Test new feature dialog opens throws and error to the
        user when no name is provided
        """

        self.gazetteer_plugin._newfeat.trigger()
        self.trigger_new_feature_dlg()
        iface.dlg_create_new.accept()
        QTest.qWait(1000)

        # MessageBar is level WARNING
        self.assertEqual(iface.messageBar().currentItem().level(), 2)
        self.assertEqual(
            iface.messageBar().currentItem().children()[2].toPlainText(),
            "New feature errors: You must enter a name for the new feature",
        )
        iface.messageBar().clearWidgets()
        self.close_new_feature_dlg()

    def test_invalid_lon_not_in_range(self):
        self.gazetteer_plugin._newfeat.trigger()
        # QTimer.singleShot(0, self.trigger_new_feature_dlg)
        self.trigger_new_feature_dlg()
        QTest.qWait(1000)
        iface.dlg_create_new.uFeatName.setText("test123")
        iface.dlg_create_new.uLongitude.setText("-42")
        iface.dlg_create_new.accept()

        # MessageBar is level WARNING
        self.assertEqual(iface.messageBar().currentItem().level(), 2)
        self.assertEqual(
            iface.messageBar().currentItem().children()[2].toPlainText(),
            "New feature errors: The longitude must be in the range 0 to 360 degrees",
        )
        iface.messageBar().clearWidgets()
        self.close_new_feature_dlg()

    def test_invalid_geom_lat_lon(self):
        self.gazetteer_plugin._newfeat.trigger()
        self.trigger_new_feature_dlg(600, 42.576)
        iface.dlg_create_new.uFeatName.setText("test123")

        # MessageBar is level WARNING
        self.assertEqual(iface.messageBar().currentItem().level(), 2)
        self.assertEqual(
            iface.messageBar().currentItem().children()[2].toPlainText(),
            "Gazetter location error: The location selected for the new feature is not at a valid latitude and longitude",
        )
        iface.messageBar().clearWidgets()
        self.close_new_feature_dlg()

    def test_new_feature(self):
        feature_name = "Ashburton Folks"
        feature_x = 169.82699229328563
        feature_y = -44.200093724057346
        self.trigger_new_feature_dlg(feature_x, feature_y)
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()

        # Check the a new dockwidgettab has been added with the features name
        self.assertEqual(
            self.gazetteer_plugin._editor.findChildren(QTabBar)[1].tabText(
                self.gazetteer_plugin._editor.findChildren(QTabBar)[1].currentIndex()
            ),
            feature_name,
        )
        # Whats is populated in the webView
        web_view = [
            dock_widget.widget()
            for dock_widget in self.gazetteer_plugin._editor.findChildren(QDockWidget)
            if dock_widget.__class__.__name__ == "NameWebDock"
        ][0]

        # Elements
        html_doc = web_view.page().mainFrame().documentElement().document()
        data_div_paragraphs = html_doc.findAll("div p")
        header = html_doc.findFirst("div.data h1").toPlainText()
        subheaders = html_doc.findAll("div.data h2")

        # check header = feature_name
        self.assertEqual(header, feature_name)

        # Check process value
        process = data_div_paragraphs[2].toPlainText()
        self.assertEqual(process, "Process: None")

        # Check status value
        process = data_div_paragraphs[3].toPlainText()
        self.assertEqual(process, "Status: New name")

        # Check header (Other Names)
        subheader = subheaders[0].toPlainText()
        self.assertEqual(subheader, "Other names")

        # Check status value
        other_names = data_div_paragraphs[4].toPlainText()
        self.assertEqual(other_names, "There are no other names for this feature.")

        # Check header (Feature information)
        subheader = subheaders[1].toPlainText()
        self.assertEqual(subheader, "Feature information")

        # Check Feature type value
        feature_type = data_div_paragraphs[6].toPlainText()
        self.assertEqual(feature_type, "Feature type: Locality (NZ - Place)")

        # Check Description value
        description = data_div_paragraphs[7].toPlainText()
        self.assertEqual(description, "Description:")

        # # Check lat_lon value
        # lat_lon = data_div_paragraphs[8].toPlainText()
        # self.assertEqual(
        #     lat_lon,
        #     "Longitude/latitude: 169 49 35.9E 44 11 59.1S (169.826646 -44.199761)",
        # )

        # # Check NZTM value
        # nztm = data_div_paragraphs[9].toPlainText()
        # self.assertEqual(nztm, "NZTM: 1346435.5 5101010.0")

        # Check header (Feature information)
        subheader = subheaders[2].toPlainText()
        self.assertEqual(subheader, "Feature annotations")

        # Check feature_info value
        feature_info = data_div_paragraphs[13].toPlainText()
        self.assertEqual(feature_info, "There are no annotations for this feature")

        # Check header (Events)
        subheader = subheaders[3].toPlainText()
        self.assertEqual(subheader, "Events")

        # Check events value
        events = data_div_paragraphs[15].toPlainText()
        self.assertEqual(events, "There are no events associated with this name")

        # Check header (Name annotations)
        subheader = subheaders[4].toPlainText()
        self.assertEqual(subheader, "Name annotations")

        # Check name_annotation value
        name_annotation = data_div_paragraphs[17].toPlainText()
        self.assertEqual(name_annotation, "There are no annotations for this name")

        # Check header (Feature/Name associations)
        subheader = subheaders[5].toPlainText()
        self.assertEqual(subheader, "Feature/Name associations")

        # Check associations value
        associations = data_div_paragraphs[20].toPlainText()
        self.assertEqual(
            associations,
            "There are no other names or features associated with this one.",
        )

        newest_feat = self.test_data_handler.last_modified_feature(feature_name)
        self.assertEqual(newest_feat[2], feature_name)

        # Check the edit elements are not visible to the QWebView
        self.assertFalse(web_view.findText("Edit name"))
        self.assertFalse(web_view.findText("Create new name for this feature"))
        self.assertFalse(web_view.findText("Create new feature annotation"))
        self.assertFalse(web_view.findText("Create new event"))
        self.assertFalse(web_view.findText("Create new name annotation"))
        self.assertFalse(web_view.findText("Create new association"))

    def test_click_edit_btn(self):
        feature_name = "Ashburton Folks"
        feature_x = 169.82699229328563
        feature_y = -44.200093724057346
        self.trigger_new_feature_dlg(feature_x, feature_y)
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()

        web_view = [
            dock_widget.widget()
            for dock_widget in self.gazetteer_plugin._editor.findChildren(QDockWidget)
            if dock_widget.__class__.__name__ == "NameWebDock"
        ][0]

        html_doc = web_view.page().mainFrame().documentElement().document()
        # Click the edit button
        html_doc.findAll("input[name=Edit]")[0].evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # Check edit text is enabled in form
        self.assertTrue(
            web_view.findText("Edit name", QWebPage.HighlightAllOccurrences)
        )
        QTest.qWait(self.voluntary_wait)
        web_view.findText("")

        self.assertTrue(
            web_view.findText(
                "Create new name for this feature", QWebPage.HighlightAllOccurrences
            )
        )
        QTest.qWait(self.voluntary_wait)
        web_view.findText("")

        self.assertTrue(
            web_view.findText(
                "Create new feature annotation", QWebPage.HighlightAllOccurrences
            )
        )
        QTest.qWait(self.voluntary_wait)
        web_view.findText("")

        self.assertTrue(
            web_view.findText("Create new event", QWebPage.HighlightAllOccurrences)
        )
        QTest.qWait(self.voluntary_wait)
        web_view.findText("")
        self.assertTrue(
            web_view.findText(
                "Create new name annotation", QWebPage.HighlightAllOccurrences
            )
        )
        QTest.qWait(self.voluntary_wait)
        web_view.findText("")

        self.assertTrue(
            web_view.findText(
                "Create new association", QWebPage.HighlightAllOccurrences
            )
        )
        QTest.qWait(self.voluntary_wait)
        web_view.findText("")

        # Disbale editing
        html_doc.findAll("input[name=Cancel]")[0].evaluateJavaScript("this.click()")

    def test_edit_process():

        html_doc = web_view.page().mainFrame().documentElement().document()
        # click on process combobox
        html_doc.findAll("div a")[3].evaluateJavaScript("this.click()")
        # Change selection
        html_doc.findAll("div a")[3].findAll('select[name="name_process"]')[
            0
        ].evaluateJavaScript("this.selectedIndex=1")


def suite():
    suite = unittest.TestSuite()
    suite.addTests(unittest.makeSuite(UnitLevel, "test"))
    return suite


def run_tests():
    unittest.TextTestRunner(verbosity=3).run(suite())
