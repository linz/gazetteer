import unittest
from io import StringIO
import sys
import re

from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qgis.core import QgsProject, QgsPointXY
from qgis.utils import plugins, iface, reloadPlugin
from PyQt5.QtTest import QTest
from qgis.gui import QgsMapTool
from PyQt5.QtWebKitWidgets import QWebPage

from utils.data_handler import TestDataHandler


class CaptureStdOut(list):
    """
    Context manager to capture qt evaluateJavaScript stdOut
    as used for testing plugin JS.
    """

    def __enter__(self):
        self._stdout = sys.stdout
        sys.stdout = self._stringio = StringIO()
        return self

    def __exit__(self, *args):
        self.extend(self._stringio.getvalue().splitlines())
        del self._stringio
        sys.stdout = self._stdout


class TestNewFeature(unittest.TestCase):
    """
    Test the creating of a new feature and
    editing of values of this new feature
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

        # Remove all layers
        QgsProject.instance().removeAllMapLayers()

        # And groups
        root = QgsProject.instance().layerTreeRoot()
        for group in [child for child in root.children() if child.nodeType() == 0]:
            root.removeChildNode(group)

    def setUp(cls):
        """
        Runs before each test.
        """
        pass

    def tearDown(cls):
        """
        Runs after each test
        """
        pass

    def get_web_view(self):
        """
        Returns the QWebView reference
        """

        return [
            dock_widget.widget()
            for dock_widget in self.gazetteer_plugin._editor.findChildren(QDockWidget)
            if dock_widget.__class__.__name__ == "NameWebDock"
        ][0]

    def parse_name_id(self, name_id):
        """
        Returns the plugin_id from the HTML Document
        i.e.takes 1/100 and returns the names_id (in this case "1")
        """

        p = re.compile(r"(?P<name_id>[0-9]*)\/([0-9]*)")
        m = p.search(name_id)
        return int(m.group("name_id"))

    def create_select_index(self, html_doc, select_tag):
        """
        Builds an index of html select items

        {<select items string>: {value: <select items code>, index: <select item position>}}
        """

        # get count of items in select
        with CaptureStdOut() as stdout:
            html_doc.findFirst(select_tag).evaluateJavaScript(
                "console.log(this.options.length)"
            )

        select_len = self.format_console_log(stdout[0])

        select_index = {}
        for i in range(0, int(select_len)):
            with CaptureStdOut() as stdout:
                html_doc.findFirst(select_tag).evaluateJavaScript(
                    f"console.log(this.options[{i}].text)"
                )
            text = self.format_console_log(stdout[0])
            with CaptureStdOut() as stdout:
                html_doc.findFirst(select_tag).evaluateJavaScript(
                    f"console.log(this.options[{i}].value)"
                )
            value = self.format_console_log(stdout[0])

            select_index[text] = {"index": i, "value": value}
        return select_index

    def trigger_new_feature_dlg(self, x=174.76318, y=-41.28338):
        """
        Clicks on the map canvas and triggers the new feature dlg
        """

        self.gazetteer_plugin._newfeat.trigger()
        widget = iface.mapCanvas().viewport()
        canvas_point = QgsMapTool(iface.mapCanvas()).toCanvasCoordinates
        QTest.mouseClick(
            widget, Qt.LeftButton, pos=canvas_point(QgsPointXY(x, y)), delay=0
        )
        QTest.qWait(1000)

    def close_new_feature_dlg(self):
        """
        Closes the new feature dialog
        """

        QTest.qWait(500)
        iface.dlg_create_new.close()

    @staticmethod
    def format_console_log(msg):
        """
        Format the output from calling evaluateJavaScript() on the
        HTML edit feature document
        """

        p = re.compile(r"(Message:\s\s)(?P<stdout>.*)(\s\s\(.*)")
        m = p.search(msg)
        return m.group("stdout")

    def test_A_new_feature_dlg(self):
        """
        Test the new feature dialog opens on map canvas click
        """

        # Mimic user selecting new feature tool
        self.trigger_new_feature_dlg()
        self.assertEquals(iface.dlg_create_new.uFeatName.text(), "")
        self.close_new_feature_dlg()

    def test_B_new_feature_dlg_name_missing(self):
        """
        Test the new feature dialog throws an error to the
        user when no name is provided
        """

        self.trigger_new_feature_dlg()
        iface.dlg_create_new.accept()
        QTest.qWait(500)

        # MessageBar is level WARNING
        self.assertEqual(iface.messageBar().currentItem().level(), 2)
        self.assertEqual(
            iface.messageBar().currentItem().children()[2].toPlainText(),
            "New feature errors: You must enter a name for the new feature",
        )
        iface.messageBar().clearWidgets()
        self.close_new_feature_dlg()

    def test_C_invalid_lon_not_in_range(self):
        """
        Ensure error thrown when an invalid longitude is supplied
        """

        self.trigger_new_feature_dlg()

        # Set new feature values
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

    def test_D_invalid_geom_lat_lon(self):
        """
        Ensure error thrown when an invalid geom value is supplied
        """

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

    def test_E_new_feature_document_content(self):
        """
        Create a new feature and ensure the state of the
        HMTL feature summary document is as expected
        """

        # The New Feature to use for the test
        feature_name = "Ashburton Folks"
        feature_x = 169.82699229328563
        feature_y = -44.200093724057346

        # Trigger the new feature dlg and populated it
        self.trigger_new_feature_dlg(feature_x, feature_y)
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()
        QTest.qWait(500)

        # Check the a new dockwidgettab has been added with the features name
        self.assertEqual(
            self.gazetteer_plugin._editor.findChildren(QTabBar)[1].tabText(
                self.gazetteer_plugin._editor.findChildren(QTabBar)[1].currentIndex()
            ),
            feature_name,
        )

        # Get reference to the webview
        web_view = self.get_web_view()
        html_doc = web_view.page().mainFrame().documentElement().document()

        # html doc components
        data_div_paragraphs = html_doc.findAll("div p")
        header = html_doc.findFirst("div.data h1").toPlainText()
        subheaders = html_doc.findAll("div.data h2")

        # get name_id - this is also the DB PK this allows access to the DB record
        name_id = self.parse_name_id(
            html_doc.findFirst('div[class="idblock"]').toPlainText().strip(" ")
        )

        # check header = feature_name
        self.assertEqual(header, feature_name)

        # Check process value - Should be None
        process = data_div_paragraphs[2].toPlainText()
        self.assertEqual(process, "Process: None")

        # Check status value - Should indicate a new name
        process = data_div_paragraphs[3].toPlainText()
        self.assertEqual(process, "Status: Proposed")

        # Check header (Other Names)
        subheader = subheaders[0].toPlainText()
        self.assertEqual(subheader, "Other names")

        # Check status value - Should indicate no other names
        other_names = data_div_paragraphs[4].toPlainText()
        self.assertEqual(other_names, "There are no other names for this feature.")

        # Check header (Feature information)
        subheader = subheaders[1].toPlainText()
        self.assertEqual(subheader, "Feature information")

        # Check Feature type value - Should indicate Locality / NZ Place
        feature_type = data_div_paragraphs[6].toPlainText()
        self.assertEqual(feature_type, "Feature type: Locality (NZ - Place)")

        # Check Description value - Should be "Description"
        description = data_div_paragraphs[7].toPlainText()
        self.assertEqual(description, "Description:")

        # To do// Must be investigated
        # These lat/long values are not mapped
        # through to the form consistently
        # See - https://github.com/linz/gazetteer/issues/149
        # # Check lat_lon value
        # lat_lon = data_div_paragraphs[8].toPlainText()
        # self.assertEqual(
        #     lat_lon,
        #     "Longitude/latitude: 169 49 37.9E 44 11 59.7S (169.827208 -44.199921)",
        # )

        # # Check NZTM value
        # nztm = data_div_paragraphs[9].toPlainText()
        # self.assertEqual(nztm, "NZTM: 1346435.5 5101010.0")

        # Check header (Feature information)
        subheader = subheaders[2].toPlainText()
        self.assertEqual(subheader, "Feature annotations")

        # Check feature_info value - Should indicate there are none
        feature_info = data_div_paragraphs[13].toPlainText()
        self.assertEqual(feature_info, "There are no annotations for this feature")

        # Check header (Events)
        subheader = subheaders[3].toPlainText()
        self.assertEqual(subheader, "Events")

        # Check events value - Should indicate there are none
        events = data_div_paragraphs[15].toPlainText()
        self.assertEqual(events, "There are no events associated with this name")

        # Check header (Name annotations)
        subheader = subheaders[4].toPlainText()
        self.assertEqual(subheader, "Name annotations")

        # Check name_annotation value - Should indicate there are none
        name_annotation = data_div_paragraphs[17].toPlainText()
        self.assertEqual(name_annotation, "There are no annotations for this name")

        # Check header (Feature/Name associations)
        subheader = subheaders[5].toPlainText()
        self.assertEqual(subheader, "Feature/Name associations")

        # Check associations value - Should indicate there are none
        associations = data_div_paragraphs[20].toPlainText()
        self.assertEqual(
            associations,
            "There are no other names or features associated with this one.",
        )

        # Check the database record exists for the id
        newest_feat = self.data_handler.last_added_feature()
        self.assertEqual(
            newest_feat[0][2], feature_name
        )  # [first record][feature_name column]
        self.assertEqual(
            newest_feat[0][0], name_id
        )  # [first record][feature_id column]

        # Check the edit elements are not visible to the QWebView
        self.assertFalse(web_view.findText("Edit name"))
        self.assertFalse(web_view.findText("Create new name for this feature"))
        self.assertFalse(web_view.findText("Create new feature annotation"))
        self.assertFalse(web_view.findText("Create new event"))
        self.assertFalse(web_view.findText("Create new name annotation"))
        self.assertFalse(web_view.findText("Create new association"))

    def test_F_click_edit_btn(self):
        """
        Make document editable and test the under lying
        HTML represents the editable form
        """

        # The New Feature to use for the test
        feature_name = "Ashburton Folks"
        feature_x = 169.82699229328563
        feature_y = -44.200093724057346

        # Trigger the new feature dlg and populated it
        self.trigger_new_feature_dlg(feature_x, feature_y)
        QTest.qWait(500)
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()

        # Get the HTML document
        web_view = self.get_web_view()
        html_doc = web_view.page().mainFrame().documentElement().document()

        # Click the edit button
        html_doc.findFirst("input[name=Edit]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # Check edit text is enabled in form

        # text associated with edit hrefs that is only
        # in the HTML when editing is enabled
        expected_text = [
            "Edit name",
            "Create new name for this feature",
            "Create new feature annotation",
            "Create new event",
            "Create new name annotation",
            "Create new association",
        ]

        # Iterate over the expected text and ensure it is in the
        # edit enabled form
        for text in expected_text:
            self.assertTrue(web_view.findText(text, QWebPage.HighlightAllOccurrences))
            # Just for visual output when monitoring live in QGIS
            QTest.qWait(self.voluntary_wait)

            # Clear Highlighting
            web_view.findText("")

        # Disbale editing
        html_doc.findFirst("input[name=Cancel]").evaluateJavaScript("this.click()")

    def test_G_edit_process(self):
        """
        Edit the features "process" value
        """

        # The New Feature to use for the test
        feature_name = "Ashburton Folks"
        feature_x = 169.82699229328563
        feature_y = -44.200093724057346

        # Trigger the new feature dlg and populated it
        self.trigger_new_feature_dlg(feature_x, feature_y)
        QTest.qWait(500)
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()

        # Get the HTML document
        web_view = self.get_web_view()
        html_doc = web_view.page().mainFrame().documentElement().document()

        # get name_id - this allows access to the DB record
        name_id = self.parse_name_id(
            html_doc.findFirst('div[class="idblock"]').toPlainText().strip(" ")
        )

        # Check the DB 'process' value
        db_feature_record = self.data_handler.get_feature_by_id(name_id)
        self.assertIsNone(db_feature_record[0][3])

        # click on edit process type
        html_doc.findAll("div a")[3].evaluateJavaScript("this.click()")
        QTest.qWait(self.voluntary_wait)

        # Make sure this test is not returning a false positive
        # Assert the select value is not 'FATR)' to begin with
        with CaptureStdOut() as stdout:
            html_doc.findFirst('select[name="name_process"]').evaluateJavaScript(
                "console.log(this.value)"
            )

        self.assertNotEqual(self.format_console_log(stdout[0]), "FATR)")

        # get count of items in select
        with CaptureStdOut() as stdout:
            html_doc.findFirst('select[name="name_process"]').evaluateJavaScript(
                "console.log(this.options.length)"
            )

        # Get an mapping of select item's text and index
        select_index = self.create_select_index(html_doc, 'select[name="name_process"]')
        # using the index value to change the features process_type to
        # "Fast Track Recorded (NZGB Act 2008 ss.24, 21)"
        update_index_value = select_index[
            "Fast Track Recorded (NZGB Act 2008 ss.24, 21)"
        ]["index"]

        js_update_index = f"this.selectedIndex={update_index_value}; this.dispatchEvent(new Event('change'))"

        # Perform selectedIndex update
        html_doc.findFirst('select[name="name_process"]').evaluateJavaScript(
            js_update_index
        )

        # Check the index changed
        with CaptureStdOut() as stdout:
            html_doc.findFirst('select[name="name_process"]').evaluateJavaScript(
                "console.log(this.value)"
            )

        self.assertEqual(self.format_console_log(stdout[0]), "FATR")

        # Click Save
        html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # Check the DB record has been updated
        db_feature_record = self.data_handler.get_feature_by_id(name_id)
        self.assertEqual(db_feature_record[0][3], "FATR")

        # Part-2: Check and edit that name status in this same test
        # as status is tied to process type
        web_view = self.get_web_view()
        html_doc = web_view.page().mainFrame().documentElement().document()

        # click on edit status
        html_doc.findAll("div a")[5].evaluateJavaScript("this.click()")
        QTest.qWait(self.voluntary_wait)

        # Get a mapping of select item's text and index
        select_index = self.create_select_index(html_doc, 'select[name="name_status"]')

        # check the select is populated with the correct options
        self.assertListEqual(
            [v["value"] for v in select_index.values()],
            ["OAPP", "UDEL", "UDIS", "MRNM", "UNEW", "UREC"],
        )

        # using the index value change the features status to Discontinued
        update_index_value = select_index["Discontinued"]["index"]
        js_update_index = f"this.selectedIndex={update_index_value}; this.dispatchEvent(new Event('change'))"

        # Perform selectedIndex update
        html_doc.findFirst('select[name="name_status"]').evaluateJavaScript(
            js_update_index
        )

        # Check the index changed
        with CaptureStdOut() as stdout:
            html_doc.findFirst('select[name="name_status"]').evaluateJavaScript(
                "console.log(this.value )"
            )

        self.assertEqual(self.format_console_log(stdout[0]), "UDIS")

        html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        db_feature_record = self.data_handler.get_feature_by_id(name_id)
        self.assertEqual(db_feature_record[0][4], "UDIS")

    def test_H_edit_name(self):
        """
        Edit the features "name" value
        """

        feature_name = "Ashburton Folks"
        feature_x = 169.82699229328563
        feature_y = -44.200093724057346
        self.trigger_new_feature_dlg(feature_x, feature_y)
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()

        # Get the HTML document
        web_view = self.get_web_view()
        html_doc = web_view.page().mainFrame().documentElement().document()

        # get name_id - this allows access to the DB record
        name_id = self.parse_name_id(
            html_doc.findFirst('div[class="idblock"]').toPlainText().strip(" ")
        )

        # Feature name as per UI
        header = html_doc.findFirst("div.data h1").toPlainText()

        # click edit name
        html_doc.findFirst("a[id=new_name_edit_edit_link]").evaluateJavaScript(
            "this.click()"
        )

        # TODO
        # Check field for new name appears

        # Change text
        # Not proving so straight forward...

    def test_I_other_name(self):
        """
        Add an "other name" for the feature
        """

        # The below needs to go some where modular
        feature_name = "Ashburton Folks"
        feature_x = 169.82699229328563
        feature_y = -44.200093724057346
        self.trigger_new_feature_dlg(feature_x, feature_y)
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()

        # Get the HTML document
        web_view = self.get_web_view()
        html_doc = web_view.page().mainFrame().documentElement().document()

        # Click the edit button
        html_doc.findFirst("input[name=Edit]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # Click "Create new name for this feature" Btn (there must be a better
        # way to reference this)
        html_doc.findAll("a")[6].evaluateJavaScript("this.click()")

        # add new name
        html_doc.findFirst('input[id="other_name"]').evaluateJavaScript(
            """this.value = 'Something Else'; this.dispatchEvent(new Event('change'))"""
        )

        # save
        html_doc.findFirst('input[id="other_name"]').evaluateJavaScript("this.blur()")
        html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")

        # Check it is displayed
        # Get the HTML document
        web_view = self.get_web_view()
        html_doc = web_view.page().mainFrame().documentElement().document()

        self.assertEqual(
            html_doc.findAll("p")[4].toPlainText(), "Something Else (Proposed)"
        )
