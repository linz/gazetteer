import unittest
from io import StringIO
import sys
import re
import xml.etree.ElementTree as ET

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
        # cls.data_handler.delete_sys_codes() # TEMP Commented out

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
        cls.html_doc = None
        cls.web_view = None
        cls.feat_id = None

    def tearDown(cls):
        """
        Runs after each test
        """
        pass

    def init_edit_feature(
        self, feature_name="Ashburton Folks", feature_x=169.8269, feature_y=-44.2000
    ):

        self.trigger_new_feature_dlg(feature_x, feature_y)
        iface.dlg_create_new.uFeatName.setText(feature_name)
        iface.dlg_create_new.accept()

        # Get the HTML document
        self.web_view = self.get_web_view()
        self.html_doc = self.web_view.page().mainFrame().documentElement().document()

        # Click the edit button
        self.html_doc.findFirst("input[name=Edit]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # get feature_id - this allows access to the DB record
        self.name_id, self.feat_id = self.parse_id(
            self.html_doc.findFirst('div[class="idblock"]').toPlainText().strip(" ")
        )

    def get_web_view(self):
        """
        Returns the QWebView reference
        """

        return [
            dock_widget.widget()
            for dock_widget in self.gazetteer_plugin._editor.findChildren(QDockWidget)
            if dock_widget.__class__.__name__ == "NameWebDock"
        ][0]

    def parse_id(self, id):
        """
        Returns the name and feature id from the HTML Document
        """

        p = re.compile(r"(?P<name_id>[0-9]*)\/(?P<feat_id>[0-9]*)")
        m = p.search(id)
        return int(m.group("name_id")), int(m.group("feat_id"))

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
        self.web_view = self.get_web_view()
        self.html_doc = self.web_view.page().mainFrame().documentElement().document()

        # html doc components
        data_div_paragraphs = self.html_doc.findAll("div p")
        header = self.html_doc.findFirst("div.data h1").toPlainText()
        subheaders = self.html_doc.findAll("div.data h2")

        # get name_id - this is also the DB PK this allows access to the DB record
        name_id = self.parse_id(
            self.html_doc.findFirst('div[class="idblock"]').toPlainText().strip(" ")
        )[0]

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
        self.assertFalse(self.web_view.findText("Edit name"))
        self.assertFalse(self.web_view.findText("Create new name for this feature"))
        self.assertFalse(self.web_view.findText("Create new feature annotation"))
        self.assertFalse(self.web_view.findText("Create new event"))
        self.assertFalse(self.web_view.findText("Create new name annotation"))
        self.assertFalse(self.web_view.findText("Create new association"))

    def test_F_click_edit_btn(self):
        """
        Make document editable and test the under lying
        HTML represents the editable form
        """

        self.init_edit_feature()

        # Check edit text is enabled in form

        # text associated with edit hrefs that is only
        # in the HTML when editing is enabled
        expected_text = [
            "Edit name",
            "Create new name for this feature",
            "Create new feature annotation",
        ]

        # Iterate over the expected text and ensure it is in the
        # edit enabled form
        for text in expected_text:
            self.assertTrue(
                self.web_view.findText(text, QWebPage.HighlightAllOccurrences)
            )
            # Just for visual output when monitoring live in QGIS
            QTest.qWait(self.voluntary_wait)

            # Clear Highlighting
            self.web_view.findText("")

        # Disbale editing
        self.html_doc.findFirst("input[name=Cancel]").evaluateJavaScript("this.click()")

    def test_G_edit_process(self):
        """
        Edit the features "process" value
        """

        self.init_edit_feature()

        # Check the DB 'process' value
        db_feature_record = self.data_handler.get_name_by_id(self.name_id)
        self.assertIsNone(db_feature_record[0][3])

        # click on edit process type
        self.html_doc.findAll("div a")[3].evaluateJavaScript("this.click()")
        QTest.qWait(self.voluntary_wait)

        # Make sure this test is not returning a false positive
        # Assert the select value is not 'FATR)' to begin with
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst('select[name="name_process"]').evaluateJavaScript(
                "console.log(this.value)"
            )

        self.assertNotEqual(self.format_console_log(stdout[0]), "FATR)")

        # Get an mapping of select item's text and index
        xmlstring = self.html_doc.findFirst('select[name="name_process"]').toOuterXml()
        select_index = self.xml_to_select_index(xmlstring)

        # using the index value to change the features process_type to
        # "Fast Track Recorded (NZGB Act 2008 ss.24, 21)"
        update_index_value = select_index[
            "Fast Track Recorded (NZGB Act 2008 ss.24, 21)"
        ]["index"]

        js_update_index = f"this.selectedIndex={update_index_value}; this.dispatchEvent(new Event('change'))"

        # Perform selectedIndex update
        self.html_doc.findFirst('select[name="name_process"]').evaluateJavaScript(
            js_update_index
        )

        # Check the index changed
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst('select[name="name_process"]').evaluateJavaScript(
                "console.log(this.value)"
            )

        self.assertEqual(self.format_console_log(stdout[0]), "FATR")

        # Click Save
        self.html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # Check the DB record has been updated
        db_feature_record = self.data_handler.get_name_by_id(self.name_id)
        self.assertEqual(db_feature_record[0][3], "FATR")

        # Part-2: Check and edit that name status in this same test
        # as status is tied to process type
        self.web_view = self.get_web_view()
        self.html_doc = self.web_view.page().mainFrame().documentElement().document()

        # click on edit status
        self.html_doc.findAll("div a")[5].evaluateJavaScript("this.click()")
        QTest.qWait(self.voluntary_wait)

        # Get a mapping of select item's text and index
        xmlstring = self.html_doc.findFirst('select[name="name_status"]').toOuterXml()
        select_index = self.xml_to_select_index(xmlstring)

        # check the select is populated with the correct options
        self.assertListEqual(
            [v["value"] for v in select_index.values()],
            ["OAPP", "UDEL", "UDIS", "MRNM", "UNEW", "UREC"],
        )

        # using the index value change the features status to Discontinued
        update_index_value = select_index["Discontinued"]["index"]
        js_update_index = f"this.selectedIndex={update_index_value}; this.dispatchEvent(new Event('change'))"

        # Perform selectedIndex update
        self.html_doc.findFirst('select[name="name_status"]').evaluateJavaScript(
            js_update_index
        )

        # Check the index changed
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst('select[name="name_status"]').evaluateJavaScript(
                "console.log(this.value )"
            )

        self.assertEqual(self.format_console_log(stdout[0]), "UDIS")

        self.html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        db_feature_record = self.data_handler.get_name_by_id(self.name_id)
        self.assertEqual(db_feature_record[0][4], "UDIS")

    def test_H_edit_name(self):
        """
        Edit the features "name" value
        """

        self.init_edit_feature()

        # Feature name as per UI
        header = self.html_doc.findFirst("div.data h1").toPlainText()

        # click edit name
        self.html_doc.findFirst("a[id=new_name_edit_edit_link]").evaluateJavaScript(
            "this.click()"
        )

        # Check the name in the input
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst(
                f"""input[id="Name_{self.name_id}.name"]"""
            ).evaluateJavaScript("console.log(this.value )")
        self.assertEqual(self.format_console_log(stdout[0]), "Ashburton Folks")

        # Change name text (to "Something Else")
        self.html_doc.findFirst(
            f"""input[id="Name_{self.name_id}.name"]"""
        ).evaluateJavaScript(
            """this.value = 'Something Else'; this.dispatchEvent(new Event('change'))"""
        )

        # Save the edit
        self.html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")

        # Check the forms name
        web_view = self.get_web_view()
        self.html_doc = web_view.page().mainFrame().documentElement().document()
        header = self.html_doc.findFirst("div.data h1").toPlainText()

        # Check the record has change in the DB
        db_feature_record = self.data_handler.get_name_by_id(self.name_id)
        self.assertEqual("Something Else", db_feature_record[0][2])

    def test_I_other_name(self):
        """
        Add an "other name" for the feature
        """

        self.init_edit_feature()

        # Click "Create new name for this feature" Btn (there must be a better
        # way to reference this)
        self.html_doc.findAll("a")[6].evaluateJavaScript("this.click()")

        # add new name
        self.html_doc.findFirst('input[id="other_name"]').evaluateJavaScript(
            """this.value = 'Something Else'; this.dispatchEvent(new Event('change'))"""
        )

        # save
        self.html_doc.findFirst('input[id="other_name"]').evaluateJavaScript(
            "this.blur()"
        )
        self.html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")

        # Check it is displayed
        # Get the HTML document
        self.web_view = self.get_web_view()
        self.html_doc = self.web_view.page().mainFrame().documentElement().document()

        self.assertEqual(
            self.html_doc.findAll("p")[4].toPlainText(), "Something Else (Proposed)"
        )

    def test_J_edit_description(self):

        self.init_edit_feature()

        # Click description edit btn
        self.html_doc.findAll("div a")[8].evaluateJavaScript("this.click()")

        # Check the value is not already == WATR
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst(
                'select[name="feat_type_category"]'
            ).evaluateJavaScript("console.log(this.value)")

        self.assertNotEqual(self.format_console_log(stdout[0]), "WATR)")

        # Get an mapping of select item's text and index

        xmlstring = self.html_doc.findFirst(
            'select[name="feat_type_category"]'
        ).toOuterXml()
        select_index = self.xml_to_select_index(xmlstring)

        # using the index value to change the features process_type to
        # "Fast Track Recorded (NZGB Act 2008 ss.24, 21)"
        update_index_value = select_index["NZ - Water"]["index"]

        js_update_index = f"this.selectedIndex={update_index_value}; this.dispatchEvent(new Event('change'))"

        # Perform selectedIndex update
        self.html_doc.findFirst('select[name="feat_type_category"]').evaluateJavaScript(
            js_update_index
        )

        # Check the index changed - feat_type_category
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst(
                'select[name="feat_type_category"]'
            ).evaluateJavaScript("console.log(this.value)")

        self.assertEqual(self.format_console_log(stdout[0]), "WATR")

        # And feat_type is now a water type
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst('select[name="feat_type"]').evaluateJavaScript(
                "console.log(this.value)"
            )

        self.assertEqual(self.format_console_log(stdout[0]), "FORD")

        # A description must also be provided
        self.html_doc.findFirst(
            f"""textarea[id="Feature_{self.feat_id}.description"]"""
        ).evaluateJavaScript(
            """this.value = 'A new water feature'; this.dispatchEvent(new Event('change'))"""
        )

        # Click Save
        self.html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # Check the html doc has updated
        self.web_view = self.get_web_view()
        self.html_doc = self.web_view.page().mainFrame().documentElement().document()

        self.assertEqual(
            self.html_doc.findAll(f'div[id="Feature_{self.feat_id}"]')[0]
            .findAll("p")[0]
            .toPlainText(),
            "Feature type: Ford (NZ - Water)",
        )
        self.assertEqual(
            self.html_doc.findAll(f'div[id="Feature_{self.feat_id}"]')[0]
            .findAll("p")[1]
            .toPlainText(),
            "Description: A new water feature",
        )

        # Check the feature DB record has been updated
        db_feature_record = self.data_handler.get_feature_by_id(self.feat_id)
        self.assertEqual(db_feature_record[0][1], "FORD")
        self.assertEqual(db_feature_record[0][3], "A new water feature")

    # def test_K_edit_coordinates(self):

    #     self.init_edit_feature()

    #     # Click description edit btn
    #     html_doc.findAll("div a")[10].evaluateJavaScript("this.click()")

    #     # Add new cords
    #     html_doc.findFirst(
    #         f"""input[id="Feature_{feat_id}.setLocation"]"""
    #     ).evaluateJavaScript(
    #         """this.value = '1343461.3 5098601.0'; this.dispatchEvent(new Event('change'))"""
    #     )

    #     # TODO// FAILING see - https://github.com/linz/gazetteer/issues/151

    def test_L_edit_feature_annotation(self):
        self.init_edit_feature()

        # Click annotations edit btn
        self.html_doc.findAll("div a")[11].evaluateJavaScript("this.click()")

        # Check value is not already "Land District"
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst(
                'select[name="annotation_type"]'
            ).evaluateJavaScript("console.log(this.value)")

        self.assertNotEqual(self.format_console_log(stdout[0]), "LDIS")

        # Get an mapping of select item's text and index

        xmlstring = self.html_doc.findFirst(
            'select[name="annotation_type"]'
        ).toOuterXml()
        select_index = self.xml_to_select_index(xmlstring)

        # using the index value to change the features annotation_type to LDIS
        update_index_value = select_index["Land district"]["index"]

        js_update_index = f"this.selectedIndex={update_index_value}; this.dispatchEvent(new Event('change'))"

        # Perform selectedIndex update
        self.html_doc.findFirst('select[name="annotation_type"]').evaluateJavaScript(
            js_update_index
        )

        # Check the index changed
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst(
                'select[name="annotation_type"]'
            ).evaluateJavaScript("console.log(this.value)")

        self.assertEqual(self.format_console_log(stdout[0]), "LDIS")

        # Now edit the annotation text
        self.html_doc.findFirst(f"textarea[name='annotation']").evaluateJavaScript(
            """this.value = 'An annotation'; this.dispatchEvent(new Event('change'))"""
        )

        # Click Save
        self.html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # Test the HTML updated
        self.web_view = self.get_web_view()
        self.html_doc = self.web_view.page().mainFrame().documentElement().document()

        # And the database has updated
        db_annotation_record = self.data_handler.get_feat_annotation_by_id(self.feat_id)
        self.assertEqual(db_annotation_record[0][2], "LDIS")
        self.assertEqual(db_annotation_record[0][3], "An annotation")

    def test_M_edit_event(self):
        self.init_edit_feature()

        # Click annotations edit btn
        self.html_doc.findAll("div a")[12].evaluateJavaScript("this.click()")

        # Check value is not already "NZGB/New Zealand Geographic Board"
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst('select[name="event_type"]').evaluateJavaScript(
                "console.log(this.value)"
            )

        self.assertNotEqual(self.format_console_log(stdout[0]), "NZGZ")

        # Make sure there are no date or ref related errors
        self.assertEqual(
            self.html_doc.findFirst('div[object_type="Event"]')
            .findFirst('div[class="errors"]')
            .toPlainText(),
            "You must supply an event date\n\nYou must supply a reference for the event\n\n",
        )

        # Get an mapping of select item's text and index
        xmlstring = self.html_doc.findFirst('select[name="event_type"]').toOuterXml()
        select_index_type = self.xml_to_select_index(xmlstring)

        # Using the index value to change the features Authority select to NZGB/New Zealand Geographic Board
        update_index_value = select_index_type["NZGB gazettal"]["index"]

        js_update_index = f"this.selectedIndex={update_index_value}; this.dispatchEvent(new Event('change'))"

        # Perform selectedIndex update
        self.html_doc.findFirst('select[name="event_type"]').evaluateJavaScript(
            js_update_index
        )

        # Check the index changed
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst('select[name="event_type"]').evaluateJavaScript(
                "console.log(this.value)"
            )

        self.assertEqual(self.format_console_log(stdout[0]), "NZGZ")

        # Get an mapping of select item's text and index
        xmlstring = self.html_doc.findFirst('select[name="authority"]').toOuterXml()
        select_index_auth = self.xml_to_select_index(xmlstring)

        # using the index value to change the features event type to NZGB/New Zealand Geographic Board
        update_index_value = select_index_auth["New Zealand Geographic Board"]["index"]

        js_update_index = f"this.selectedIndex={update_index_value}; this.dispatchEvent(new Event('change'))"

        # Perform selectedIndex update
        self.html_doc.findFirst('select[name="authority"]').evaluateJavaScript(
            js_update_index
        )

        # Check the index changed
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst('select[name="authority"]').evaluateJavaScript(
                "console.log(this.value)"
            )

        self.assertEqual(self.format_console_log(stdout[0]), "NZGB")

        # Now edit the date text to an invalid date
        self.html_doc.findFirst(f"input[name='event_date']").evaluateJavaScript(
            """this.value = '11-11-2015'; this.dispatchEvent(new Event('change'))"""
        )

        # Make sure there are is a date related error
        self.assertEqual(
            self.html_doc.findFirst('div[object_type="Event"]')
            .findFirst('div[class="errors"]')
            .toPlainText(),
            """Event date must be formatted as (for example) 23-Jun-2005\n\nGazette references must be formatted as "1995 (94) p.213"\n\n""",
        )
        # Now edit the date text to an valid date
        self.html_doc.findFirst(f"input[name='event_date']").evaluateJavaScript(
            """this.value = '11-Jun-2015'; this.dispatchEvent(new Event('change'))"""
        )

        # Make sure there are no date related errors
        self.assertEqual(
            self.html_doc.findFirst('div[object_type="Event"]')
            .findFirst('div[class="errors"]')
            .toPlainText(),
            'Gazette references must be formatted as "1995 (94) p.213"\n\n',
        )

        # Now edit the ref text to an invalid reference
        self.html_doc.findFirst(f"input[name='event_reference']").evaluateJavaScript(
            """this.value = 'Go look at the gazetteer'; this.dispatchEvent(new Event('change'))"""
        )

        # Make sure there are reference related errors
        self.assertEqual(
            self.html_doc.findFirst('div[object_type="Event"]')
            .findFirst('div[class="errors"]')
            .toPlainText(),
            'Gazette references must be formatted as "1995 (94) p.213"\n\n',
        )

        # Now edit the ref text to a valid reference
        self.html_doc.findFirst(f"input[name='event_reference']").evaluateJavaScript(
            """this.value = '1995 (94) p.213'; this.dispatchEvent(new Event('change'))"""
        )

        # Make sure there are no reference related errors
        self.assertEqual(
            self.html_doc.findFirst('div[object_type="Event"]')
            .findFirst('div[class="errors"]')
            .toPlainText(),
            "",
        )

        # A notes

        self.html_doc.findFirst(f"""textarea[name="notes"]""").evaluateJavaScript(
            """this.value = 'A New Note'; this.dispatchEvent(new Event('change'))"""
        )

        # Click Save
        self.html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # Test the HTML updated
        self.web_view = self.get_web_view()
        self.html_doc = self.web_view.page().mainFrame().documentElement().document()

        self.assertEqual(
            self.html_doc.findFirst('p[class="event"]').toPlainText().strip(" "),
            "NZGB gazettal (11-Jun-2015): 1995 (94) p.213",
        )

        self.assertEqual(
            self.html_doc.findFirst('p[class="eventnotes"]').toPlainText().strip(" "),
            "Notes: A New Note",
        )

        # And the database has updated
        db_event_record = self.data_handler.get_event_by_id(self.name_id)
        self.assertEqual(db_event_record[0][2].strftime("%Y-%m-%d"), "2015-06-11")
        self.assertEqual(db_event_record[0][3], "NZGZ")
        self.assertEqual(db_event_record[0][4], "NZGB")
        self.assertEqual(db_event_record[0][5], "1995 (94) p.213")
        self.assertEqual(db_event_record[0][6], "A New Note")

    def xml_to_select_index(self, xmlstring):

        root = ET.fromstring(xmlstring)
        select_index = {}
        count = 0
        for option in root.findall("option"):
            select_index[option.text] = {"index": count, "value": option.items()[0][1]}
            count += 1
        return select_index

    def test_N_edit_name_annotation(self):
        self.init_edit_feature()

        # Click annotations edit btn
        self.html_doc.findAll("div a")[13].evaluateJavaScript("this.click()")

        # Get an mapping of select item's text and index
        xmlstring = (
            self.html_doc.findFirst('div[object_type="NameAnnotation"]')
            .findFirst('select[name="annotation_type"]')
            .toOuterXml()
        )
        select_index = self.xml_to_select_index(xmlstring)

        # using the index value to change the features annotation_type to LDIS
        update_index_value = select_index["Māori Name"]["index"]

        js_update_index = f"this.selectedIndex={update_index_value}; this.dispatchEvent(new Event('change'))"

        # Perform selectedIndex update
        self.html_doc.findFirst('div[object_type="NameAnnotation"]').findFirst(
            'select[name="annotation_type"]'
        ).evaluateJavaScript(js_update_index)

        # Check the index changed
        with CaptureStdOut() as stdout:
            self.html_doc.findFirst('div[object_type="NameAnnotation"]').findFirst(
                'select[name="annotation_type"]'
            ).evaluateJavaScript("console.log(this.value)")

        self.assertEqual(self.format_console_log(stdout[0]), "MRIN")

        # make sure there are no errors
        self.assertEqual(
            self.html_doc.findFirst('div[object_type="NameAnnotation"]')
            .findFirst('div[class="errors"]')
            .toPlainText(),
            "",
        )

        # Now edit the annotation text with an invalid input
        self.html_doc.findFirst('div[object_type="NameAnnotation"]').findFirst(
            f"textarea[name='annotation']"
        ).evaluateJavaScript(
            """this.value = 'An annotation'; this.dispatchEvent(new Event('change'))"""
        )

        # make sure there is an error
        self.assertEqual(
            self.html_doc.findFirst('div[object_type="NameAnnotation"]')
            .findFirst('div[class="errors"]')
            .toPlainText(),
            'Māori name flag must be one of "Yes", "No", "TBI"\n\n',
        )

        # Now edit the annotation text with an valid input
        self.html_doc.findFirst('div[object_type="NameAnnotation"]').findFirst(
            f"textarea[name='annotation']"
        ).evaluateJavaScript(
            """this.value = 'Yes'; this.dispatchEvent(new Event('change'))"""
        )
        # Click Save
        self.html_doc.findFirst("input[name=Save]").evaluateJavaScript("this.click()")
        QTest.qWait(700)

        # Test the HTML updated
        self.web_view = self.get_web_view()
        self.html_doc = self.web_view.page().mainFrame().documentElement().document()

        self.assertEqual(
            self.html_doc.findFirst('p[class="annot"]').toPlainText().strip(" "),
            "Māori Name: Yes",
        )

        # And the database has updated
        db_annotation_record = self.data_handler.get_name_annotation_by_id(self.name_id)
        self.assertEqual(db_annotation_record[0][2], "MRIN")
        self.assertEqual(db_annotation_record[0][3], "Yes")

    # def test_O_edit_associations(self):
    #     # Create the feature we will associated with
    #     self.init_edit_feature(feature_name="Ashburton")
    #     self.init_edit_feature()

    #     # tabs.setCurrentIndex(0)
    #     search_table = (
    #         self.gazetteer_plugin._editor._searchWindow.widget().uSearchResults
    #     )
    #     self.assertEqualassert(
    #         self.gazetteer_plugin._editor.findChildren(QTabBar)[1].tabText(0), "Search"
    #     )
    #     self.gazetteer_plugin._editor.findChildren(QTabBar)[1].setCurrentIndex(0)

    #     # Click the Search Button
    #     self.gazetteer_plugin._editor._searchWindow.widget().uSearchButton.triggered

    #     # Set the search Text
    #     search_table.setText("ashburton")

    #     # Get ref to record
    #     search_table.model().index(1, 0).data()

    #     # # Get data
    #     result = (
    #         self.gazetteer_plugin._editor._searchWindow.widget()
    #         .uSearchResults.model()
    #         .index(1, 0)
    #     )
    #     self.assertEqual(result.data(), "Ashburton")
