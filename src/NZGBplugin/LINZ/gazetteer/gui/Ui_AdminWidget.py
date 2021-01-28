# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Ui_AdminWidget.ui'
#
# Created by: PyQt5 UI code generator 5.10.1
#
# WARNING! All changes made in this file will be lost!

from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_AdminWidget(object):
    def setupUi(self, AdminWidget):
        AdminWidget.setObjectName("AdminWidget")
        AdminWidget.resize(561, 537)
        self.verticalLayout = QtWidgets.QVBoxLayout(AdminWidget)
        self.verticalLayout.setObjectName("verticalLayout")
        self.tabWidget = QtWidgets.QTabWidget(AdminWidget)
        self.tabWidget.setObjectName("tabWidget")
        self.tab = QtWidgets.QWidget()
        self.tab.setObjectName("tab")
        self.verticalLayout_4 = QtWidgets.QVBoxLayout(self.tab)
        self.verticalLayout_4.setObjectName("verticalLayout_4")
        self.label = QtWidgets.QLabel(self.tab)
        self.label.setWordWrap(True)
        self.label.setObjectName("label")
        self.verticalLayout_4.addWidget(self.label)
        self.uLastUpdateLabel = QtWidgets.QLabel(self.tab)
        self.uLastUpdateLabel.setText("")
        self.uLastUpdateLabel.setObjectName("uLastUpdateLabel")
        self.verticalLayout_4.addWidget(self.uLastUpdateLabel)
        spacerItem = QtWidgets.QSpacerItem(
            20, 40, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding
        )
        self.verticalLayout_4.addItem(spacerItem)
        self.horizontalLayout_3 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_3.setContentsMargins(-1, 0, -1, -1)
        self.horizontalLayout_3.setObjectName("horizontalLayout_3")
        spacerItem1 = QtWidgets.QSpacerItem(
            40, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum
        )
        self.horizontalLayout_3.addItem(spacerItem1)
        self.uPublishDatabase = QtWidgets.QPushButton(self.tab)
        self.uPublishDatabase.setObjectName("uPublishDatabase")
        self.horizontalLayout_3.addWidget(self.uPublishDatabase)
        self.uDownloadCSV = QtWidgets.QPushButton(self.tab)
        self.uDownloadCSV.setObjectName("uDownloadCSV")
        self.horizontalLayout_3.addWidget(self.uDownloadCSV)
        spacerItem2 = QtWidgets.QSpacerItem(
            40, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum
        )
        self.horizontalLayout_3.addItem(spacerItem2)
        self.verticalLayout_4.addLayout(self.horizontalLayout_3)
        spacerItem3 = QtWidgets.QSpacerItem(
            20, 40, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding
        )
        self.verticalLayout_4.addItem(spacerItem3)
        self.uUpdatingLabel = QtWidgets.QLabel(self.tab)
        font = QtGui.QFont()
        font.setPointSize(12)
        font.setBold(True)
        font.setWeight(75)
        self.uUpdatingLabel.setFont(font)
        self.uUpdatingLabel.setAlignment(QtCore.Qt.AlignCenter)
        self.uUpdatingLabel.setObjectName("uUpdatingLabel")
        self.verticalLayout_4.addWidget(self.uUpdatingLabel)
        spacerItem4 = QtWidgets.QSpacerItem(
            20, 140, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding
        )
        self.verticalLayout_4.addItem(spacerItem4)
        self.tabWidget.addTab(self.tab, "")
        self.tab_2 = QtWidgets.QWidget()
        self.tab_2.setObjectName("tab_2")
        self.verticalLayout_3 = QtWidgets.QVBoxLayout(self.tab_2)
        self.verticalLayout_3.setObjectName("verticalLayout_3")
        self.label_2 = QtWidgets.QLabel(self.tab_2)
        self.label_2.setObjectName("label_2")
        self.verticalLayout_3.addWidget(self.label_2)
        self.label_4 = QtWidgets.QLabel(self.tab_2)
        self.label_4.setWordWrap(True)
        self.label_4.setObjectName("label_4")
        self.verticalLayout_3.addWidget(self.label_4)
        self.uUsersTable = ListModelTableView(self.tab_2)
        self.uUsersTable.setObjectName("uUsersTable")
        self.verticalLayout_3.addWidget(self.uUsersTable)
        self.label_5 = QtWidgets.QLabel(self.tab_2)
        self.label_5.setObjectName("label_5")
        self.verticalLayout_3.addWidget(self.label_5)
        self.horizontalLayout = QtWidgets.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.label_3 = QtWidgets.QLabel(self.tab_2)
        self.label_3.setObjectName("label_3")
        self.horizontalLayout.addWidget(self.label_3)
        self.uUserName = QtWidgets.QLineEdit(self.tab_2)
        self.uUserName.setObjectName("uUserName")
        self.horizontalLayout.addWidget(self.uUserName)
        self.uUserIsAdmin = QtWidgets.QCheckBox(self.tab_2)
        self.uUserIsAdmin.setObjectName("uUserIsAdmin")
        self.horizontalLayout.addWidget(self.uUserIsAdmin)
        self.verticalLayout_3.addLayout(self.horizontalLayout)
        self.horizontalLayout_2 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        self.uAddUser = QtWidgets.QPushButton(self.tab_2)
        self.uAddUser.setObjectName("uAddUser")
        self.horizontalLayout_2.addWidget(self.uAddUser)
        self.uUpdateUser = QtWidgets.QPushButton(self.tab_2)
        self.uUpdateUser.setObjectName("uUpdateUser")
        self.horizontalLayout_2.addWidget(self.uUpdateUser)
        self.uRemoveUser = QtWidgets.QPushButton(self.tab_2)
        self.uRemoveUser.setObjectName("uRemoveUser")
        self.horizontalLayout_2.addWidget(self.uRemoveUser)
        self.verticalLayout_3.addLayout(self.horizontalLayout_2)
        self.tabWidget.addTab(self.tab_2, "")
        self.tab_3 = QtWidgets.QWidget()
        self.tab_3.setObjectName("tab_3")
        self.verticalLayout_2 = QtWidgets.QVBoxLayout(self.tab_3)
        self.verticalLayout_2.setObjectName("verticalLayout_2")
        self.uSystemCodeWidget = SystemCodeEditorWidget(self.tab_3)
        self.uSystemCodeWidget.setObjectName("uSystemCodeWidget")
        self.verticalLayout_2.addWidget(self.uSystemCodeWidget)
        self.tabWidget.addTab(self.tab_3, "")
        self.verticalLayout.addWidget(self.tabWidget)

        self.retranslateUi(AdminWidget)
        self.tabWidget.setCurrentIndex(0)
        QtCore.QMetaObject.connectSlotsByName(AdminWidget)

    def retranslateUi(self, AdminWidget):
        _translate = QtCore.QCoreApplication.translate
        AdminWidget.setWindowTitle(_translate("AdminWidget", "Form"))
        self.label.setText(
            _translate(
                "AdminWidget",
                "Use this button to update the published data on the web application, LDS, and CSV files.\n"
                "This will publish the data for all publishable names.\n"
                "\n"
                'Check the advanced search for status  (Unpublished) and for "names with not published annotation" to see what will not be published.\n'
                "\n"
                "When you run the update the web database may be unavailable for about 5 minutes while this update runs.",
            )
        )
        self.uPublishDatabase.setText(_translate("AdminWidget", "Publish data"))
        self.uDownloadCSV.setText(_translate("AdminWidget", "Download CSV"))
        self.uUpdatingLabel.setText(
            _translate("AdminWidget", "Updating web database - please wait .....")
        )
        self.tabWidget.setTabText(
            self.tabWidget.indexOf(self.tab),
            _translate("AdminWidget", "Publish gazetteer data"),
        )
        self.label_2.setText(
            _translate(
                "AdminWidget",
                "Administer gazetteer application users.  Users must have a network login.  ",
            )
        )
        self.label_4.setText(
            _translate(
                "AdminWidget",
                "Admin users can use the admin screens to update the web database, add and remove users, and update systems codes",
            )
        )
        self.label_5.setText(
            _translate(
                "AdminWidget",
                "To add a new user, just enter their network login userid below and click Add.",
            )
        )
        self.label_3.setText(_translate("AdminWidget", "User name"))
        self.uUserIsAdmin.setText(_translate("AdminWidget", "Admin user"))
        self.uAddUser.setText(_translate("AdminWidget", "Add"))
        self.uUpdateUser.setText(_translate("AdminWidget", "Update"))
        self.uRemoveUser.setText(_translate("AdminWidget", "Remove"))
        self.tabWidget.setTabText(
            self.tabWidget.indexOf(self.tab_2), _translate("AdminWidget", "Users")
        )
        self.tabWidget.setTabText(
            self.tabWidget.indexOf(self.tab_3),
            _translate("AdminWidget", "System Codes"),
        )


from .SystemCodeEditorWidget import SystemCodeEditorWidget
from LINZ.Widgets.ListModelConnector import ListModelTableView
