# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Ui_AdminWidget.ui'
#
# Created: Fri Sep 19 12:48:00 2014
#      by: PyQt4 UI code generator 4.10.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

class Ui_AdminWidget(object):
    def setupUi(self, AdminWidget):
        AdminWidget.setObjectName(_fromUtf8("AdminWidget"))
        AdminWidget.resize(561, 537)
        self.verticalLayout = QtGui.QVBoxLayout(AdminWidget)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))
        self.tabWidget = QtGui.QTabWidget(AdminWidget)
        self.tabWidget.setObjectName(_fromUtf8("tabWidget"))
        self.tab = QtGui.QWidget()
        self.tab.setObjectName(_fromUtf8("tab"))
        self.verticalLayout_4 = QtGui.QVBoxLayout(self.tab)
        self.verticalLayout_4.setObjectName(_fromUtf8("verticalLayout_4"))
        self.label = QtGui.QLabel(self.tab)
        self.label.setWordWrap(True)
        self.label.setObjectName(_fromUtf8("label"))
        self.verticalLayout_4.addWidget(self.label)
        self.uLastUpdateLabel = QtGui.QLabel(self.tab)
        self.uLastUpdateLabel.setText(_fromUtf8(""))
        self.uLastUpdateLabel.setObjectName(_fromUtf8("uLastUpdateLabel"))
        self.verticalLayout_4.addWidget(self.uLastUpdateLabel)
        spacerItem = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_4.addItem(spacerItem)
        self.horizontalLayout_3 = QtGui.QHBoxLayout()
        self.horizontalLayout_3.setContentsMargins(-1, 0, -1, -1)
        self.horizontalLayout_3.setObjectName(_fromUtf8("horizontalLayout_3"))
        spacerItem1 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_3.addItem(spacerItem1)
        self.uPublishDatabase = QtGui.QPushButton(self.tab)
        self.uPublishDatabase.setObjectName(_fromUtf8("uPublishDatabase"))
        self.horizontalLayout_3.addWidget(self.uPublishDatabase)
        self.uDownloadCSV = QtGui.QPushButton(self.tab)
        self.uDownloadCSV.setObjectName(_fromUtf8("uDownloadCSV"))
        self.horizontalLayout_3.addWidget(self.uDownloadCSV)
        spacerItem2 = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.horizontalLayout_3.addItem(spacerItem2)
        self.verticalLayout_4.addLayout(self.horizontalLayout_3)
        spacerItem3 = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_4.addItem(spacerItem3)
        self.uUpdatingLabel = QtGui.QLabel(self.tab)
        font = QtGui.QFont()
        font.setPointSize(12)
        font.setBold(True)
        font.setWeight(75)
        self.uUpdatingLabel.setFont(font)
        self.uUpdatingLabel.setAlignment(QtCore.Qt.AlignCenter)
        self.uUpdatingLabel.setObjectName(_fromUtf8("uUpdatingLabel"))
        self.verticalLayout_4.addWidget(self.uUpdatingLabel)
        spacerItem4 = QtGui.QSpacerItem(20, 140, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_4.addItem(spacerItem4)
        self.tabWidget.addTab(self.tab, _fromUtf8(""))
        self.tab_2 = QtGui.QWidget()
        self.tab_2.setObjectName(_fromUtf8("tab_2"))
        self.verticalLayout_3 = QtGui.QVBoxLayout(self.tab_2)
        self.verticalLayout_3.setObjectName(_fromUtf8("verticalLayout_3"))
        self.label_2 = QtGui.QLabel(self.tab_2)
        self.label_2.setObjectName(_fromUtf8("label_2"))
        self.verticalLayout_3.addWidget(self.label_2)
        self.label_4 = QtGui.QLabel(self.tab_2)
        self.label_4.setWordWrap(True)
        self.label_4.setObjectName(_fromUtf8("label_4"))
        self.verticalLayout_3.addWidget(self.label_4)
        self.uUsersTable = ListModelTableView(self.tab_2)
        self.uUsersTable.setObjectName(_fromUtf8("uUsersTable"))
        self.verticalLayout_3.addWidget(self.uUsersTable)
        self.label_5 = QtGui.QLabel(self.tab_2)
        self.label_5.setObjectName(_fromUtf8("label_5"))
        self.verticalLayout_3.addWidget(self.label_5)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.label_3 = QtGui.QLabel(self.tab_2)
        self.label_3.setObjectName(_fromUtf8("label_3"))
        self.horizontalLayout.addWidget(self.label_3)
        self.uUserName = QtGui.QLineEdit(self.tab_2)
        self.uUserName.setObjectName(_fromUtf8("uUserName"))
        self.horizontalLayout.addWidget(self.uUserName)
        self.uUserIsAdmin = QtGui.QCheckBox(self.tab_2)
        self.uUserIsAdmin.setObjectName(_fromUtf8("uUserIsAdmin"))
        self.horizontalLayout.addWidget(self.uUserIsAdmin)
        self.verticalLayout_3.addLayout(self.horizontalLayout)
        self.horizontalLayout_2 = QtGui.QHBoxLayout()
        self.horizontalLayout_2.setObjectName(_fromUtf8("horizontalLayout_2"))
        self.uAddUser = QtGui.QPushButton(self.tab_2)
        self.uAddUser.setObjectName(_fromUtf8("uAddUser"))
        self.horizontalLayout_2.addWidget(self.uAddUser)
        self.uUpdateUser = QtGui.QPushButton(self.tab_2)
        self.uUpdateUser.setObjectName(_fromUtf8("uUpdateUser"))
        self.horizontalLayout_2.addWidget(self.uUpdateUser)
        self.uRemoveUser = QtGui.QPushButton(self.tab_2)
        self.uRemoveUser.setObjectName(_fromUtf8("uRemoveUser"))
        self.horizontalLayout_2.addWidget(self.uRemoveUser)
        self.verticalLayout_3.addLayout(self.horizontalLayout_2)
        self.tabWidget.addTab(self.tab_2, _fromUtf8(""))
        self.tab_3 = QtGui.QWidget()
        self.tab_3.setObjectName(_fromUtf8("tab_3"))
        self.verticalLayout_2 = QtGui.QVBoxLayout(self.tab_3)
        self.verticalLayout_2.setObjectName(_fromUtf8("verticalLayout_2"))
        self.uSystemCodeWidget = SystemCodeEditorWidget(self.tab_3)
        self.uSystemCodeWidget.setObjectName(_fromUtf8("uSystemCodeWidget"))
        self.verticalLayout_2.addWidget(self.uSystemCodeWidget)
        self.tabWidget.addTab(self.tab_3, _fromUtf8(""))
        self.verticalLayout.addWidget(self.tabWidget)

        self.retranslateUi(AdminWidget)
        self.tabWidget.setCurrentIndex(0)
        QtCore.QMetaObject.connectSlotsByName(AdminWidget)

    def retranslateUi(self, AdminWidget):
        AdminWidget.setWindowTitle(_translate("AdminWidget", "Form", None))
        self.label.setText(_translate("AdminWidget", "Use this button to update the published data on the web application, LDS, and CSV files.\n"
"This will publish the data for all publishable names.\n"
"\n"
"Check the advanced search for status  (Unpublished) and for \"names with not published annotation\" to see what will not be published.\n"
"\n"
"When you run the update the web database may be unavailable for about 5 minutes while this update runs.", None))
        self.uPublishDatabase.setText(_translate("AdminWidget", "Publish data", None))
        self.uDownloadCSV.setText(_translate("AdminWidget", "Download CSV", None))
        self.uUpdatingLabel.setText(_translate("AdminWidget", "Updating web database - please wait .....", None))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab), _translate("AdminWidget", "Publish gazetteer data", None))
        self.label_2.setText(_translate("AdminWidget", "Administer gazetteer application users.  Users must have a network login.  ", None))
        self.label_4.setText(_translate("AdminWidget", "Admin users can use the admin screens to update the web database, add and remove users, and update systems codes", None))
        self.label_5.setText(_translate("AdminWidget", "To add a new user, just enter their network login userid below and click Add.", None))
        self.label_3.setText(_translate("AdminWidget", "User name", None))
        self.uUserIsAdmin.setText(_translate("AdminWidget", "Admin user", None))
        self.uAddUser.setText(_translate("AdminWidget", "Add", None))
        self.uUpdateUser.setText(_translate("AdminWidget", "Update", None))
        self.uRemoveUser.setText(_translate("AdminWidget", "Remove", None))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab_2), _translate("AdminWidget", "Users", None))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab_3), _translate("AdminWidget", "System Codes", None))

from LINZ.Widgets.ListModelConnector import ListModelTableView
from SystemCodeEditorWidget import SystemCodeEditorWidget
