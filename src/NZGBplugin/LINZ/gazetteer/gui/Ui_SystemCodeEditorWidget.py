# -*- coding: utf-8 -*-
################################################################################
#
#  New Zealand Geographic Board gazetteer application,
#  Crown copyright (c) 2020, Land Information New Zealand on behalf of
#  the New Zealand Government.
#
#  This file is released under the MIT licence. See the LICENCE file found
#  in the top-level directory of this distribution for more information.
#
################################################################################


# Form implementation generated from reading ui file 'Ui_SystemCodeEditorWidget.ui'
#
# Created: Thu Feb 28 12:30:01 2013
#      by: PyQt4 UI code generator 4.8.5
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_SystemCodeEditorWidget(object):
    def setupUi(self, SystemCodeEditorWidget):
        SystemCodeEditorWidget.setObjectName(_fromUtf8("SystemCodeEditorWidget"))
        SystemCodeEditorWidget.resize(567, 367)
        SystemCodeEditorWidget.setWindowTitle(QtGui.QApplication.translate("SystemCodeEditorWidget", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.verticalLayout_2 = QtGui.QVBoxLayout(SystemCodeEditorWidget)
        self.verticalLayout_2.setObjectName(_fromUtf8("verticalLayout_2"))
        self.horizontalLayout_2 = QtGui.QHBoxLayout()
        self.horizontalLayout_2.setObjectName(_fromUtf8("horizontalLayout_2"))
        self.label_2 = QtGui.QLabel(SystemCodeEditorWidget)
        self.label_2.setText(QtGui.QApplication.translate("SystemCodeEditorWidget", "System code group", None, QtGui.QApplication.UnicodeUTF8))
        self.label_2.setObjectName(_fromUtf8("label_2"))
        self.horizontalLayout_2.addWidget(self.label_2)
        self.uCodeGroupSelector = PythonComboBox(SystemCodeEditorWidget)
        self.uCodeGroupSelector.setObjectName(_fromUtf8("uCodeGroupSelector"))
        self.horizontalLayout_2.addWidget(self.uCodeGroupSelector)
        self.horizontalLayout_2.setStretch(1, 1)
        self.verticalLayout_2.addLayout(self.horizontalLayout_2)
        self.splitter = QtGui.QSplitter(SystemCodeEditorWidget)
        self.splitter.setOrientation(QtCore.Qt.Vertical)
        self.splitter.setObjectName(_fromUtf8("splitter"))
        self.horizontalLayoutWidget = QtGui.QWidget(self.splitter)
        self.horizontalLayoutWidget.setObjectName(_fromUtf8("horizontalLayoutWidget"))
        self.horizontalLayout = QtGui.QHBoxLayout(self.horizontalLayoutWidget)
        self.horizontalLayout.setContentsMargins(-1, -1, -1, 0)
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.uCodesTable = ListModelTableView(self.horizontalLayoutWidget)
        self.uCodesTable.setObjectName(_fromUtf8("uCodesTable"))
        self.horizontalLayout.addWidget(self.uCodesTable)
        self.verticalLayout = QtGui.QVBoxLayout()
        self.verticalLayout.setContentsMargins(-1, -1, 0, -1)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))
        self.uNewCodeButton = QtGui.QPushButton(self.horizontalLayoutWidget)
        self.uNewCodeButton.setEnabled(False)
        self.uNewCodeButton.setText(QtGui.QApplication.translate("SystemCodeEditorWidget", "New", None, QtGui.QApplication.UnicodeUTF8))
        self.uNewCodeButton.setObjectName(_fromUtf8("uNewCodeButton"))
        self.verticalLayout.addWidget(self.uNewCodeButton)
        self.uDeleteCodeButton = QtGui.QPushButton(self.horizontalLayoutWidget)
        self.uDeleteCodeButton.setEnabled(False)
        self.uDeleteCodeButton.setText(QtGui.QApplication.translate("SystemCodeEditorWidget", "Delete", None, QtGui.QApplication.UnicodeUTF8))
        self.uDeleteCodeButton.setObjectName(_fromUtf8("uDeleteCodeButton"))
        self.verticalLayout.addWidget(self.uDeleteCodeButton)
        spacerItem = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout.addItem(spacerItem)
        self.horizontalLayout.addLayout(self.verticalLayout)
        self.frame = QtGui.QFrame(self.splitter)
        self.frame.setFrameShape(QtGui.QFrame.StyledPanel)
        self.frame.setFrameShadow(QtGui.QFrame.Raised)
        self.frame.setObjectName(_fromUtf8("frame"))
        self.horizontalLayout_4 = QtGui.QHBoxLayout(self.frame)
        self.horizontalLayout_4.setObjectName(_fromUtf8("horizontalLayout_4"))
        self.uCodeEditor = ConnectedWidget(self.frame)
        self.uCodeEditor.setObjectName(_fromUtf8("uCodeEditor"))
        self.horizontalLayout_3 = QtGui.QHBoxLayout(self.uCodeEditor)
        self.horizontalLayout_3.setMargin(0)
        self.horizontalLayout_3.setObjectName(_fromUtf8("horizontalLayout_3"))
        self.formLayout = QtGui.QFormLayout()
        self.formLayout.setObjectName(_fromUtf8("formLayout"))
        self.label = QtGui.QLabel(self.uCodeEditor)
        self.label.setText(QtGui.QApplication.translate("SystemCodeEditorWidget", "Code", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setObjectName(_fromUtf8("label"))
        self.formLayout.setWidget(0, QtGui.QFormLayout.LabelRole, self.label)
        self.label_3 = QtGui.QLabel(self.uCodeEditor)
        self.label_3.setText(QtGui.QApplication.translate("SystemCodeEditorWidget", "Category", None, QtGui.QApplication.UnicodeUTF8))
        self.label_3.setObjectName(_fromUtf8("label_3"))
        self.formLayout.setWidget(1, QtGui.QFormLayout.LabelRole, self.label_3)
        self.label_4 = QtGui.QLabel(self.uCodeEditor)
        self.label_4.setText(QtGui.QApplication.translate("SystemCodeEditorWidget", "Value", None, QtGui.QApplication.UnicodeUTF8))
        self.label_4.setObjectName(_fromUtf8("label_4"))
        self.formLayout.setWidget(2, QtGui.QFormLayout.LabelRole, self.label_4)
        self.label_5 = QtGui.QLabel(self.uCodeEditor)
        self.label_5.setText(QtGui.QApplication.translate("SystemCodeEditorWidget", "Description", None, QtGui.QApplication.UnicodeUTF8))
        self.label_5.setObjectName(_fromUtf8("label_5"))
        self.formLayout.setWidget(3, QtGui.QFormLayout.LabelRole, self.label_5)
        self.code_code = QtGui.QLineEdit(self.uCodeEditor)
        self.code_code.setInputMethodHints(QtCore.Qt.ImhUppercaseOnly)
        self.code_code.setObjectName(_fromUtf8("code_code"))
        self.formLayout.setWidget(0, QtGui.QFormLayout.FieldRole, self.code_code)
        self.code_category = QtGui.QComboBox(self.uCodeEditor)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.code_category.sizePolicy().hasHeightForWidth())
        self.code_category.setSizePolicy(sizePolicy)
        self.code_category.setObjectName(_fromUtf8("code_category"))
        self.formLayout.setWidget(1, QtGui.QFormLayout.FieldRole, self.code_category)
        self.code_value = QtGui.QLineEdit(self.uCodeEditor)
        self.code_value.setObjectName(_fromUtf8("code_value"))
        self.formLayout.setWidget(2, QtGui.QFormLayout.FieldRole, self.code_value)
        self.code_description = QtGui.QPlainTextEdit(self.uCodeEditor)
        self.code_description.setObjectName(_fromUtf8("code_description"))
        self.formLayout.setWidget(3, QtGui.QFormLayout.FieldRole, self.code_description)
        self.horizontalLayout_3.addLayout(self.formLayout)
        self.verticalLayout_3 = QtGui.QVBoxLayout()
        self.verticalLayout_3.setObjectName(_fromUtf8("verticalLayout_3"))
        self.code_save_button = QtGui.QPushButton(self.uCodeEditor)
        self.code_save_button.setEnabled(False)
        self.code_save_button.setText(QtGui.QApplication.translate("SystemCodeEditorWidget", "Save", None, QtGui.QApplication.UnicodeUTF8))
        self.code_save_button.setObjectName(_fromUtf8("code_save_button"))
        self.verticalLayout_3.addWidget(self.code_save_button)
        self.code_cancel_button = QtGui.QPushButton(self.uCodeEditor)
        self.code_cancel_button.setEnabled(False)
        self.code_cancel_button.setText(QtGui.QApplication.translate("SystemCodeEditorWidget", "Cancel", None, QtGui.QApplication.UnicodeUTF8))
        self.code_cancel_button.setObjectName(_fromUtf8("code_cancel_button"))
        self.verticalLayout_3.addWidget(self.code_cancel_button)
        spacerItem1 = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.verticalLayout_3.addItem(spacerItem1)
        self.horizontalLayout_3.addLayout(self.verticalLayout_3)
        self.horizontalLayout_4.addWidget(self.uCodeEditor)
        self.verticalLayout_2.addWidget(self.splitter)

        self.retranslateUi(SystemCodeEditorWidget)
        QtCore.QMetaObject.connectSlotsByName(SystemCodeEditorWidget)

    def retranslateUi(self, SystemCodeEditorWidget):
        pass

from LINZ.Widgets.ListModelConnector import ListModelTableView
from LINZ.Widgets.PythonComboBox import PythonComboBox
from LINZ.Widgets.ConnectedWidget import ConnectedWidget
