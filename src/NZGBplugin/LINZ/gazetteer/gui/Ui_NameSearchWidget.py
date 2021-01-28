# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'LINZ/gazetteer/gui/Ui_NameSearchWidget.ui'
#
# Created by: PyQt5 UI code generator 5.9.2
#
# WARNING! All changes made in this file will be lost!

from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_NameSearchWidget(object):
    def setupUi(self, NameSearchWidget):
        NameSearchWidget.setObjectName("NameSearchWidget")
        NameSearchWidget.resize(529, 373)
        self.verticalLayout = QtWidgets.QVBoxLayout(NameSearchWidget)
        self.verticalLayout.setContentsMargins(0, 0, 0, 0)
        self.verticalLayout.setObjectName("verticalLayout")
        self.tabs = QtWidgets.QTabWidget(NameSearchWidget)
        self.tabs.setObjectName("tabs")
        self.tabSearch = QtWidgets.QWidget()
        self.tabSearch.setObjectName("tabSearch")
        self.verticalLayout_2 = QtWidgets.QVBoxLayout(self.tabSearch)
        self.verticalLayout_2.setObjectName("verticalLayout_2")
        self.horizontalLayout = QtWidgets.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.uSearchText = QtWidgets.QLineEdit(self.tabSearch)
        self.uSearchText.setObjectName("uSearchText")
        self.horizontalLayout.addWidget(self.uSearchText)
        self.uSearchButton = QtWidgets.QToolButton(self.tabSearch)
        self.uSearchButton.setObjectName("uSearchButton")
        self.horizontalLayout.addWidget(self.uSearchButton)
        self.uClearSearch = QtWidgets.QToolButton(self.tabSearch)
        self.uClearSearch.setObjectName("uClearSearch")
        self.horizontalLayout.addWidget(self.uClearSearch)
        self.uToggleAdvanced = QtWidgets.QToolButton(self.tabSearch)
        self.uToggleAdvanced.setObjectName("uToggleAdvanced")
        self.horizontalLayout.addWidget(self.uToggleAdvanced)
        self.verticalLayout_2.addLayout(self.horizontalLayout)
        self.uSearchAdvanced = QtWidgets.QFrame(self.tabSearch)
        self.uSearchAdvanced.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.uSearchAdvanced.setFrameShadow(QtWidgets.QFrame.Raised)
        self.uSearchAdvanced.setObjectName("uSearchAdvanced")
        self.formLayout_3 = QtWidgets.QFormLayout(self.uSearchAdvanced)
        self.formLayout_3.setObjectName("formLayout_3")
        self.label_2 = QtWidgets.QLabel(self.uSearchAdvanced)
        self.label_2.setObjectName("label_2")
        self.formLayout_3.setWidget(0, QtWidgets.QFormLayout.LabelRole, self.label_2)
        self.label_3 = QtWidgets.QLabel(self.uSearchAdvanced)
        self.label_3.setObjectName("label_3")
        self.formLayout_3.setWidget(2, QtWidgets.QFormLayout.LabelRole, self.label_3)
        self.uSearchNameStatus = QtWidgets.QComboBox(self.uSearchAdvanced)
        self.uSearchNameStatus.setObjectName("uSearchNameStatus")
        self.formLayout_3.setWidget(
            2, QtWidgets.QFormLayout.FieldRole, self.uSearchNameStatus
        )
        self.uSearchMapExtent = QtWidgets.QCheckBox(self.uSearchAdvanced)
        self.uSearchMapExtent.setObjectName("uSearchMapExtent")
        self.formLayout_3.setWidget(
            4, QtWidgets.QFormLayout.FieldRole, self.uSearchMapExtent
        )
        self.uSearchUnpublished = QtWidgets.QCheckBox(self.uSearchAdvanced)
        self.uSearchUnpublished.setObjectName("uSearchUnpublished")
        self.formLayout_3.setWidget(
            3, QtWidgets.QFormLayout.FieldRole, self.uSearchUnpublished
        )
        self.label_4 = QtWidgets.QLabel(self.uSearchAdvanced)
        self.label_4.setObjectName("label_4")
        self.formLayout_3.setWidget(5, QtWidgets.QFormLayout.LabelRole, self.label_4)
        self.horizontalLayout_2 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_2.setContentsMargins(-1, 0, -1, -1)
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        self.uSearchMaxResults = QtWidgets.QSpinBox(self.uSearchAdvanced)
        self.uSearchMaxResults.setMinimum(10)
        self.uSearchMaxResults.setMaximum(1000000)
        self.uSearchMaxResults.setSingleStep(100)
        self.uSearchMaxResults.setProperty("value", 100)
        self.uSearchMaxResults.setObjectName("uSearchMaxResults")
        self.horizontalLayout_2.addWidget(self.uSearchMaxResults)
        spacerItem = QtWidgets.QSpacerItem(
            40, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum
        )
        self.horizontalLayout_2.addItem(spacerItem)
        self.formLayout_3.setLayout(
            5, QtWidgets.QFormLayout.FieldRole, self.horizontalLayout_2
        )
        self.horizontalLayout_4 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_4.setContentsMargins(-1, 0, -1, -1)
        self.horizontalLayout_4.setObjectName("horizontalLayout_4")
        self.uSearchFeatClass = QtWidgets.QComboBox(self.uSearchAdvanced)
        self.uSearchFeatClass.setObjectName("uSearchFeatClass")
        self.horizontalLayout_4.addWidget(self.uSearchFeatClass)
        self.uSearchFeatType = QtWidgets.QComboBox(self.uSearchAdvanced)
        self.uSearchFeatType.setObjectName("uSearchFeatType")
        self.horizontalLayout_4.addWidget(self.uSearchFeatType)
        self.formLayout_3.setLayout(
            0, QtWidgets.QFormLayout.FieldRole, self.horizontalLayout_4
        )
        self.verticalLayout_2.addWidget(self.uSearchAdvanced)
        self.uSearchResults = ListModelTableView(self.tabSearch)
        self.uSearchResults.setObjectName("uSearchResults")
        self.verticalLayout_2.addWidget(self.uSearchResults)
        self.uSearchStatus = QtWidgets.QLabel(self.tabSearch)
        self.uSearchStatus.setText("")
        self.uSearchStatus.setObjectName("uSearchStatus")
        self.verticalLayout_2.addWidget(self.uSearchStatus)
        self.tabs.addTab(self.tabSearch, "")
        self.tabRecent = QtWidgets.QWidget()
        self.tabRecent.setObjectName("tabRecent")
        self.verticalLayout_4 = QtWidgets.QVBoxLayout(self.tabRecent)
        self.verticalLayout_4.setObjectName("verticalLayout_4")
        self.horizontalLayout_3 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_3.setContentsMargins(-1, 0, -1, -1)
        self.horizontalLayout_3.setObjectName("horizontalLayout_3")
        self.uAllUsers = QtWidgets.QCheckBox(self.tabRecent)
        self.uAllUsers.setObjectName("uAllUsers")
        self.horizontalLayout_3.addWidget(self.uAllUsers)
        self.uEditOnly = QtWidgets.QCheckBox(self.tabRecent)
        self.uEditOnly.setObjectName("uEditOnly")
        self.horizontalLayout_3.addWidget(self.uEditOnly)
        spacerItem1 = QtWidgets.QSpacerItem(
            40, 20, QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Minimum
        )
        self.horizontalLayout_3.addItem(spacerItem1)
        self.label = QtWidgets.QLabel(self.tabRecent)
        self.label.setObjectName("label")
        self.horizontalLayout_3.addWidget(self.label)
        self.uMaxRecent = QtWidgets.QSpinBox(self.tabRecent)
        self.uMaxRecent.setMinimum(10)
        self.uMaxRecent.setMaximum(1000)
        self.uMaxRecent.setProperty("value", 50)
        self.uMaxRecent.setObjectName("uMaxRecent")
        self.horizontalLayout_3.addWidget(self.uMaxRecent)
        self.verticalLayout_4.addLayout(self.horizontalLayout_3)
        self.uRecentNames = ListModelTableView(self.tabRecent)
        self.uRecentNames.setObjectName("uRecentNames")
        self.verticalLayout_4.addWidget(self.uRecentNames)
        self.tabs.addTab(self.tabRecent, "")
        self.tabFavourites = QtWidgets.QWidget()
        self.tabFavourites.setObjectName("tabFavourites")
        self.verticalLayout_3 = QtWidgets.QVBoxLayout(self.tabFavourites)
        self.verticalLayout_3.setObjectName("verticalLayout_3")
        self.uFavourites = ListModelTableView(self.tabFavourites)
        self.uFavourites.setObjectName("uFavourites")
        self.verticalLayout_3.addWidget(self.uFavourites)
        self.tabs.addTab(self.tabFavourites, "")
        self.verticalLayout.addWidget(self.tabs)

        self.retranslateUi(NameSearchWidget)
        self.tabs.setCurrentIndex(0)
        QtCore.QMetaObject.connectSlotsByName(NameSearchWidget)

    def retranslateUi(self, NameSearchWidget):
        _translate = QtCore.QCoreApplication.translate
        NameSearchWidget.setWindowTitle(_translate("NameSearchWidget", "Form"))
        self.uSearchButton.setText(_translate("NameSearchWidget", "Search"))
        self.uClearSearch.setText(_translate("NameSearchWidget", "Clear"))
        self.uToggleAdvanced.setText(_translate("NameSearchWidget", "Advanced"))
        self.label_2.setText(_translate("NameSearchWidget", "Feature class/type"))
        self.label_3.setText(_translate("NameSearchWidget", "Name status"))
        self.uSearchMapExtent.setText(
            _translate("NameSearchWidget", "Limit search to map area")
        )
        self.uSearchUnpublished.setText(
            _translate("NameSearchWidget", 'Only names with "Not published" annotation')
        )
        self.label_4.setText(_translate("NameSearchWidget", "Maximum matches"))
        self.tabs.setTabText(
            self.tabs.indexOf(self.tabSearch), _translate("NameSearchWidget", "Search")
        )
        self.uAllUsers.setText(_translate("NameSearchWidget", "Any user"))
        self.uEditOnly.setText(_translate("NameSearchWidget", "Edited only"))
        self.label.setText(_translate("NameSearchWidget", "Max count "))
        self.tabs.setTabText(
            self.tabs.indexOf(self.tabRecent), _translate("NameSearchWidget", "Recent")
        )
        self.tabs.setTabText(
            self.tabs.indexOf(self.tabFavourites),
            _translate("NameSearchWidget", "Favourites"),
        )


from LINZ.Widgets.ListModelConnector import ListModelTableView
