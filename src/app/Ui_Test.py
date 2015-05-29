# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Ui_Test.ui'
#
# Created: Thu Mar 08 09:30:14 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_Test(object):
    def setupUi(self, Test):
        Test.setObjectName(_fromUtf8("Test"))
        Test.resize(400, 300)
        self.verticalLayout = QtGui.QVBoxLayout(Test)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setContentsMargins(-1, 0, -1, -1)
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.uFeatId = QtGui.QLineEdit(Test)
        self.uFeatId.setObjectName(_fromUtf8("uFeatId"))
        self.horizontalLayout.addWidget(self.uFeatId)
        self.uSeekButton = QtGui.QPushButton(Test)
        self.uSeekButton.setDefault(True)
        self.uSeekButton.setObjectName(_fromUtf8("uSeekButton"))
        self.horizontalLayout.addWidget(self.uSeekButton)
        self.verticalLayout.addLayout(self.horizontalLayout)
        self.fld_feat_type = QtGui.QComboBox(Test)
        self.fld_feat_type.setObjectName(_fromUtf8("fld_feat_type"))
        self.verticalLayout.addWidget(self.fld_feat_type)
        self.fld_status = QtGui.QLineEdit(Test)
        self.fld_status.setObjectName(_fromUtf8("fld_status"))
        self.verticalLayout.addWidget(self.fld_status)
        self.fld_description = QtGui.QPlainTextEdit(Test)
        self.fld_description.setObjectName(_fromUtf8("fld_description"))
        self.verticalLayout.addWidget(self.fld_description)
        self.fld_names = ListModelTableView(Test)
        self.fld_names.setObjectName(_fromUtf8("fld_names"))
        self.verticalLayout.addWidget(self.fld_names)
        self.buttonBox = QtGui.QDialogButtonBox(Test)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Close|QtGui.QDialogButtonBox.Save)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.verticalLayout.addWidget(self.buttonBox)

        self.retranslateUi(Test)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), Test.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), Test.reject)
        QtCore.QMetaObject.connectSlotsByName(Test)

    def retranslateUi(self, Test):
        Test.setWindowTitle(QtGui.QApplication.translate("Test", "Dialog", None, QtGui.QApplication.UnicodeUTF8))
        self.uSeekButton.setText(QtGui.QApplication.translate("Test", "Seek", None, QtGui.QApplication.UnicodeUTF8))

from LINZ.Widgets.ListModelConnector import ListModelTableView
