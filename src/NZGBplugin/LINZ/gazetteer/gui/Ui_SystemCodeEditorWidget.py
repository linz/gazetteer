# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'LINZ/gazetteer/gui/Ui_SystemCodeEditorWidget.ui'
#
# Created by: PyQt5 UI code generator 5.9.2
#
# WARNING! All changes made in this file will be lost!

from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_SystemCodeEditorWidget(object):
    def setupUi(self, SystemCodeEditorWidget):
        SystemCodeEditorWidget.setObjectName("SystemCodeEditorWidget")
        SystemCodeEditorWidget.resize(567, 367)
        self.verticalLayout_2 = QtWidgets.QVBoxLayout(SystemCodeEditorWidget)
        self.verticalLayout_2.setObjectName("verticalLayout_2")
        self.horizontalLayout_2 = QtWidgets.QHBoxLayout()
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        self.label_2 = QtWidgets.QLabel(SystemCodeEditorWidget)
        self.label_2.setObjectName("label_2")
        self.horizontalLayout_2.addWidget(self.label_2)
        self.uCodeGroupSelector = PythonComboBox(SystemCodeEditorWidget)
        self.uCodeGroupSelector.setObjectName("uCodeGroupSelector")
        self.horizontalLayout_2.addWidget(self.uCodeGroupSelector)
        self.horizontalLayout_2.setStretch(1, 1)
        self.verticalLayout_2.addLayout(self.horizontalLayout_2)
        self.splitter = QtWidgets.QSplitter(SystemCodeEditorWidget)
        self.splitter.setOrientation(QtCore.Qt.Vertical)
        self.splitter.setObjectName("splitter")
        self.horizontalLayoutWidget = QtWidgets.QWidget(self.splitter)
        self.horizontalLayoutWidget.setObjectName("horizontalLayoutWidget")
        self.horizontalLayout = QtWidgets.QHBoxLayout(self.horizontalLayoutWidget)
        self.horizontalLayout.setContentsMargins(0, 0, 0, 0)
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.uCodesTable = ListModelTableView(self.horizontalLayoutWidget)
        self.uCodesTable.setObjectName("uCodesTable")
        self.horizontalLayout.addWidget(self.uCodesTable)
        self.verticalLayout = QtWidgets.QVBoxLayout()
        self.verticalLayout.setContentsMargins(-1, -1, 0, -1)
        self.verticalLayout.setObjectName("verticalLayout")
        self.uNewCodeButton = QtWidgets.QPushButton(self.horizontalLayoutWidget)
        self.uNewCodeButton.setEnabled(False)
        self.uNewCodeButton.setObjectName("uNewCodeButton")
        self.verticalLayout.addWidget(self.uNewCodeButton)
        self.uDeleteCodeButton = QtWidgets.QPushButton(self.horizontalLayoutWidget)
        self.uDeleteCodeButton.setEnabled(False)
        self.uDeleteCodeButton.setObjectName("uDeleteCodeButton")
        self.verticalLayout.addWidget(self.uDeleteCodeButton)
        spacerItem = QtWidgets.QSpacerItem(
            20, 40, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding
        )
        self.verticalLayout.addItem(spacerItem)
        self.horizontalLayout.addLayout(self.verticalLayout)
        self.frame = QtWidgets.QFrame(self.splitter)
        self.frame.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame.setObjectName("frame")
        self.horizontalLayout_4 = QtWidgets.QHBoxLayout(self.frame)
        self.horizontalLayout_4.setObjectName("horizontalLayout_4")
        self.uCodeEditor = ConnectedWidget(self.frame)
        self.uCodeEditor.setObjectName("uCodeEditor")
        self.horizontalLayout_3 = QtWidgets.QHBoxLayout(self.uCodeEditor)
        self.horizontalLayout_3.setContentsMargins(0, 0, 0, 0)
        self.horizontalLayout_3.setObjectName("horizontalLayout_3")
        self.formLayout = QtWidgets.QFormLayout()
        self.formLayout.setObjectName("formLayout")
        self.label = QtWidgets.QLabel(self.uCodeEditor)
        self.label.setObjectName("label")
        self.formLayout.setWidget(0, QtWidgets.QFormLayout.LabelRole, self.label)
        self.label_3 = QtWidgets.QLabel(self.uCodeEditor)
        self.label_3.setObjectName("label_3")
        self.formLayout.setWidget(1, QtWidgets.QFormLayout.LabelRole, self.label_3)
        self.label_4 = QtWidgets.QLabel(self.uCodeEditor)
        self.label_4.setObjectName("label_4")
        self.formLayout.setWidget(2, QtWidgets.QFormLayout.LabelRole, self.label_4)
        self.label_5 = QtWidgets.QLabel(self.uCodeEditor)
        self.label_5.setObjectName("label_5")
        self.formLayout.setWidget(3, QtWidgets.QFormLayout.LabelRole, self.label_5)
        self.code_code = QtWidgets.QLineEdit(self.uCodeEditor)
        self.code_code.setInputMethodHints(QtCore.Qt.ImhUppercaseOnly)
        self.code_code.setObjectName("code_code")
        self.formLayout.setWidget(0, QtWidgets.QFormLayout.FieldRole, self.code_code)
        self.code_category = QtWidgets.QComboBox(self.uCodeEditor)
        sizePolicy = QtWidgets.QSizePolicy(
            QtWidgets.QSizePolicy.Expanding, QtWidgets.QSizePolicy.Fixed
        )
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(
            self.code_category.sizePolicy().hasHeightForWidth()
        )
        self.code_category.setSizePolicy(sizePolicy)
        self.code_category.setObjectName("code_category")
        self.formLayout.setWidget(
            1, QtWidgets.QFormLayout.FieldRole, self.code_category
        )
        self.code_value = QtWidgets.QLineEdit(self.uCodeEditor)
        self.code_value.setObjectName("code_value")
        self.formLayout.setWidget(2, QtWidgets.QFormLayout.FieldRole, self.code_value)
        self.code_description = QtWidgets.QPlainTextEdit(self.uCodeEditor)
        self.code_description.setObjectName("code_description")
        self.formLayout.setWidget(
            3, QtWidgets.QFormLayout.FieldRole, self.code_description
        )
        self.horizontalLayout_3.addLayout(self.formLayout)
        self.verticalLayout_3 = QtWidgets.QVBoxLayout()
        self.verticalLayout_3.setObjectName("verticalLayout_3")
        self.code_save_button = QtWidgets.QPushButton(self.uCodeEditor)
        self.code_save_button.setEnabled(False)
        self.code_save_button.setObjectName("code_save_button")
        self.verticalLayout_3.addWidget(self.code_save_button)
        self.code_cancel_button = QtWidgets.QPushButton(self.uCodeEditor)
        self.code_cancel_button.setEnabled(False)
        self.code_cancel_button.setObjectName("code_cancel_button")
        self.verticalLayout_3.addWidget(self.code_cancel_button)
        spacerItem1 = QtWidgets.QSpacerItem(
            20, 40, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding
        )
        self.verticalLayout_3.addItem(spacerItem1)
        self.horizontalLayout_3.addLayout(self.verticalLayout_3)
        self.horizontalLayout_4.addWidget(self.uCodeEditor)
        self.verticalLayout_2.addWidget(self.splitter)

        self.retranslateUi(SystemCodeEditorWidget)
        QtCore.QMetaObject.connectSlotsByName(SystemCodeEditorWidget)

    def retranslateUi(self, SystemCodeEditorWidget):
        _translate = QtCore.QCoreApplication.translate
        SystemCodeEditorWidget.setWindowTitle(
            _translate("SystemCodeEditorWidget", "Form")
        )
        self.label_2.setText(_translate("SystemCodeEditorWidget", "System code group"))
        self.uNewCodeButton.setText(_translate("SystemCodeEditorWidget", "New"))
        self.uDeleteCodeButton.setText(_translate("SystemCodeEditorWidget", "Delete"))
        self.label.setText(_translate("SystemCodeEditorWidget", "Code"))
        self.label_3.setText(_translate("SystemCodeEditorWidget", "Category"))
        self.label_4.setText(_translate("SystemCodeEditorWidget", "Value"))
        self.label_5.setText(_translate("SystemCodeEditorWidget", "Description"))
        self.code_save_button.setText(_translate("SystemCodeEditorWidget", "Save"))
        self.code_cancel_button.setText(_translate("SystemCodeEditorWidget", "Cancel"))


from LINZ.Widgets.ConnectedWidget import ConnectedWidget
from LINZ.Widgets.ListModelConnector import ListModelTableView
from LINZ.Widgets.PythonComboBox import PythonComboBox
