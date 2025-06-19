import unittest
import random
import string
import os

from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qgis.core import QgsProject


from qgis.utils import plugins, reloadPlugin
from PyQt5.QtTest import QTest

from utils.data_handler import TestDataHandler


class TestAdminInterface(unittest.TestCase):
    """
    Test the admin interface functionality
    """

    @classmethod
    def setUpClass(cls):
        # Insert required sys_codes to allow new feature creation
        cls.data_handler = TestDataHandler()
        cls.data_handler.insert_sys_codes()

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
        # With a clean plugin state

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

        pass

    def tearDown(cls):
        """
        Runs after each test
        """

        if hasattr(cls.gazetteer_plugin, "adminDlg"):
            cls.gazetteer_plugin.adminDlg.close()

    @staticmethod
    def get_random_string(length, chars=string.ascii_lowercase):
        """
        Used to generate random test strings
        """

        return "".join(random.choice(chars) for i in range(length))

    @staticmethod
    def activeModalWindowAccept():
        """
        Get the current active modal widget and click Yes
        """

        window = QApplication.instance().activeModalWidget()
        window.button(QMessageBox.Yes).click()

    def get_active_modal_text(self):
        """
        Get text from the active modal window
        """

        window = QApplication.instance().activeModalWidget()
        self.text = window.text()
        window.button(QMessageBox.Ok).click()

    @staticmethod
    def get_user_table_data(admin_widget):
        """
        Return user names and isDba value from user table
        """

        users = {}
        for user in admin_widget.uUsersTable.list():
            users[user.userid] = user.isdba
        return users

    def test_A_show_info(self):
        """
        Test the show info functionality
        """

        QTimer.singleShot(300, self.get_active_modal_text)
        self.gazetteer_plugin._infoaction.trigger()
        QTest.qWait(500)
        info_text = self.text.split("\n")
        self.assertEqual(info_text[0], "Application: NZGBplugin")
        self.assertEqual(info_text[1], f"Version: {self.gazetteer_plugin.Version}")
        self.assertEqual(info_text[2], f"Database host: {os.environ['PGHOST']}")
        self.assertEqual(info_text[3], f"Database name: {os.environ['PGDATABASE']}")
        self.assertEqual(info_text[4], f"Database user: {os.environ['PGUSER']}")

    def test_C_add_user(self):
        """
        Add a user via the plugin interface
        """

        self.gazetteer_plugin._adminaction.trigger()
        admin_widget = self.gazetteer_plugin.adminDlg.layout().itemAt(0).widget()
        admin_widget.uUserIsAdmin.setChecked(False)

        # select the user tab
        qtab = self.gazetteer_plugin.adminDlg.findChild(QTabWidget)
        qtab.setCurrentIndex(1)
        current_Tab = qtab.currentIndex()

        # validate the current tab is a expected
        self.assertEqual(qtab.tabText(current_Tab), "Users")

        # Count current number of users (prior to add user)
        user_count_prior = admin_widget.uUsersTable.rowCount()

        # Get a random string that represents a user name.
        # The randomness allows us to run the test many times
        user_name = self.get_random_string(10)

        # Test the user is not in user table data
        users = self.get_user_table_data(admin_widget)
        self.assertFalse(user_name in users)

        # Enter text for new user and hit 'add'
        admin_widget.uUserName.setText(user_name)
        QTimer.singleShot(500, self.activeModalWindowAccept)
        admin_widget.uAddUser.click()
        QTest.qWait(800)

        # Ensure the table data count has increased by one
        user_count_post = admin_widget.uUsersTable.rowCount()
        self.assertEqual(user_count_prior + 1, user_count_post)

        # Test the user is now in the user table data
        users = self.get_user_table_data(admin_widget)
        self.assertIn(user_name, users)

        # ensure the new user is not a dba
        self.assertFalse(users[user_name])

    def test_D_update_user(self):
        """
        Update a user via the admin interface
        """

        self.gazetteer_plugin._adminaction.trigger()
        admin_widget = self.gazetteer_plugin.adminDlg.layout().itemAt(0).widget()
        admin_widget.uUserIsAdmin.setChecked(False)

        # select the user tab
        qtab = self.gazetteer_plugin.adminDlg.findChild(QTabWidget)
        qtab.setCurrentIndex(1)
        current_Tab = qtab.currentIndex()

        # add a user
        user_name = self.get_random_string(10)

        # Enter text for new user and hit 'add'
        admin_widget.uUserName.setText(user_name)
        QTimer.singleShot(500, self.activeModalWindowAccept)
        admin_widget.uAddUser.click()
        QTest.qWait(800)

        # Test the user is now in the user table data
        users = self.get_user_table_data(admin_widget)
        self.assertIn(user_name, users)

        # ensure the new user is not a dba
        self.assertFalse(users[user_name])

        # select the new record
        source_row = admin_widget.uUsersTable.model().getIdDisplayRow(user_name)
        selected = QItemSelection()
        model = admin_widget.uUsersTable.model()
        point = model.index(source_row, 0)
        selected.select(point, point)
        admin_widget.uUsersTable.selectionModel().select(
            selected, QItemSelectionModel.ClearAndSelect | QItemSelectionModel.Rows
        )

        # Update the user to a DBA
        admin_widget.uUserIsAdmin.animateClick()
        QTest.qWait(300)
        admin_widget.uUpdateUser.click()

        # Check the user is now a DBA
        users = self.get_user_table_data(admin_widget)
        self.assertTrue(users[user_name])
        QTest.qWait(800)

    def test_E_remove_user(self):
        """
        Remove a user via the admin interface
        """

        self.gazetteer_plugin._adminaction.trigger()
        admin_widget = self.gazetteer_plugin.adminDlg.layout().itemAt(0).widget()
        admin_widget.uUserIsAdmin.setChecked(False)

        # select the user tab
        qtab = self.gazetteer_plugin.adminDlg.findChild(QTabWidget)
        qtab.setCurrentIndex(1)

        # add a user
        user_name = self.get_random_string(10)

        # Enter text for new user and hit 'add'
        admin_widget.uUserName.setText(user_name)
        QTimer.singleShot(500, self.activeModalWindowAccept)
        admin_widget.uAddUser.click()
        QTest.qWait(800)

        # Test the user is now in the user table data
        users = self.get_user_table_data(admin_widget)
        self.assertIn(user_name, users)

        # select the new record
        source_row = admin_widget.uUsersTable.model().getIdDisplayRow(user_name)
        selected = QItemSelection()
        model = admin_widget.uUsersTable.model()
        point = model.index(source_row, 0)
        selected.select(point, point)
        admin_widget.uUsersTable.selectionModel().select(
            selected, QItemSelectionModel.ClearAndSelect | QItemSelectionModel.Rows
        )

        QTest.qWait(300)

        # Remove the user
        admin_widget.uRemoveUser.animateClick()
        QTest.qWait(300)

        # Test the user has been removed
        users = self.get_user_table_data(admin_widget)
        self.assertNotIn(user_name, users)

    def test_F_add_new_sys_code(self):
        """
        Add a new sys code via the admin interface
        """

        self.gazetteer_plugin._adminaction.trigger()
        QTest.qWait(300)
        admin_widget = self.gazetteer_plugin.adminDlg.layout().itemAt(0).widget()

        # select the user tab
        qtab = self.gazetteer_plugin.adminDlg.findChild(QTabWidget)
        qtab.setCurrentIndex(2)
        current_Tab = qtab.currentIndex()
        QTest.qWait(300)

        # validate the current tab is a expected
        self.assertEqual(qtab.tabText(current_Tab), "System Codes")

        # sys code widgets
        code_widget = admin_widget.uSystemCodeWidget
        code_table = code_widget.uCodesTable

        # Add new sys code
        code_widget.uNewCodeButton.animateClick()
        QTest.qWait(300)

        code = self.get_random_string(4, string.ascii_uppercase)
        value = self.get_random_string(4, string.ascii_uppercase)

        # ensure the code is not already in the code table
        codes = [code.code for code in code_table.list()]
        self.assertNotIn(code, codes)

        code_widget.code_code.setText(code)
        code_widget.code_value.setText(value)
        code_widget.code_description.setPlainText("automated test")

        code_widget.code_save_button.animateClick()
        QTest.qWait(300)

        # Test the new record is present

        # Select new record in system code table
        source_row = code_table.model().getIdDisplayRow(code)
        selected = QItemSelection()
        model = code_table.model()
        point = model.index(source_row, 0)
        selected.select(point, point)
        code_table.selectionModel().select(
            selected, QItemSelectionModel.ClearAndSelect | QItemSelectionModel.Rows
        )

        # ensure the code is in the code table
        codes = [code.code for code in code_table.list()]
        self.assertIn(code, codes)

        # and the values are set
        code_objs = {}
        for code_data in code_table.list():
            code_objs[code_data.code] = code_data
        self.assertEqual(value, code_objs[code].value)
        self.assertEqual("automated test", code_objs[code].description)

    def test_G_delete_sys_code(self):
        """
        Delete a new sys code via the admin interface
        """

        self.gazetteer_plugin._adminaction.trigger()
        QTest.qWait(300)
        admin_widget = self.gazetteer_plugin.adminDlg.layout().itemAt(0).widget()

        # select the user tab
        qtab = self.gazetteer_plugin.adminDlg.findChild(QTabWidget)
        qtab.setCurrentIndex(2)
        current_Tab = qtab.currentIndex()
        QTest.qWait(300)

        # sys code widgets
        code_widget = admin_widget.uSystemCodeWidget
        code_table = code_widget.uCodesTable

        # Add new sys code
        code_widget.uNewCodeButton.animateClick()
        QTest.qWait(300)

        code = self.get_random_string(4, string.ascii_uppercase)
        value = self.get_random_string(4, string.ascii_uppercase)

        code_widget.code_code.setText(code)
        code_widget.code_value.setText(value)
        code_widget.code_description.setPlainText("automated test")

        code_widget.code_save_button.animateClick()
        QTest.qWait(300)

        # ensure the code is in the code table
        codes = [code.code for code in code_table.list()]
        self.assertIn(code, codes)

        # Select new record in system code table
        source_row = code_table.model().getIdDisplayRow(code)
        selected = QItemSelection()
        model = code_table.model()
        point = model.index(source_row, 0)
        selected.select(point, point)
        code_table.selectionModel().select(
            selected, QItemSelectionModel.ClearAndSelect | QItemSelectionModel.Rows
        )

        # Delete sys code
        code_widget.uDeleteCodeButton.animateClick()
        QTest.qWait(300)

        # Ensure the code has been removed
        codes = [code.code for code in code_table.list()]
        self.assertNotIn(code, codes)
