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


# Form implementation generated from reading ui file 'Ui_NewFeatureDialog.ui'
#
# Created: Mon Apr 21 12:09:47 2014
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_NewFeatureDialog(object):
    def setupUi(self, NewFeatureDialog):
        NewFeatureDialog.setObjectName(_fromUtf8("NewFeatureDialog"))
        NewFeatureDialog.resize(517, 223)
        self.verticalLayout = QtGui.QVBoxLayout(NewFeatureDialog)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))
        self.action_label = QtGui.QLabel(NewFeatureDialog)
        self.action_label.setObjectName(_fromUtf8("action_label"))
        self.verticalLayout.addWidget(self.action_label)
        self.formLayout = QtGui.QFormLayout()
        self.formLayout.setLabelAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignTop)
        self.formLayout.setFormAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.formLayout.setObjectName(_fromUtf8("formLayout"))
        self.nameLabel = QtGui.QLabel(NewFeatureDialog)
        self.nameLabel.setObjectName(_fromUtf8("nameLabel"))
        self.formLayout.setWidget(0, QtGui.QFormLayout.LabelRole, self.nameLabel)
        self.lblFeatType = QtGui.QLabel(NewFeatureDialog)
        self.lblFeatType.setObjectName(_fromUtf8("lblFeatType"))
        self.formLayout.setWidget(2, QtGui.QFormLayout.LabelRole, self.lblFeatType)
        self.uFeatName = QtGui.QLineEdit(NewFeatureDialog)
        self.uFeatName.setObjectName(_fromUtf8("uFeatName"))
        self.formLayout.setWidget(0, QtGui.QFormLayout.FieldRole, self.uFeatName)
        self.uFeatType = QtGui.QComboBox(NewFeatureDialog)
        self.uFeatType.setObjectName(_fromUtf8("uFeatType"))
        self.formLayout.setWidget(2, QtGui.QFormLayout.FieldRole, self.uFeatType)
        self.label = QtGui.QLabel(NewFeatureDialog)
        self.label.setObjectName(_fromUtf8("label"))
        self.formLayout.setWidget(1, QtGui.QFormLayout.LabelRole, self.label)
        self.uFeatTypeClass = QtGui.QComboBox(NewFeatureDialog)
        self.uFeatTypeClass.setObjectName(_fromUtf8("uFeatTypeClass"))
        self.formLayout.setWidget(1, QtGui.QFormLayout.FieldRole, self.uFeatTypeClass)
        self.uLongitude = QtGui.QLineEdit(NewFeatureDialog)
        self.uLongitude.setObjectName(_fromUtf8("uLongitude"))
        self.formLayout.setWidget(3, QtGui.QFormLayout.FieldRole, self.uLongitude)
        self.label_2 = QtGui.QLabel(NewFeatureDialog)
        self.label_2.setObjectName(_fromUtf8("label_2"))
        self.formLayout.setWidget(3, QtGui.QFormLayout.LabelRole, self.label_2)
        self.label_3 = QtGui.QLabel(NewFeatureDialog)
        self.label_3.setObjectName(_fromUtf8("label_3"))
        self.formLayout.setWidget(4, QtGui.QFormLayout.LabelRole, self.label_3)
        self.uLatitude = QtGui.QLineEdit(NewFeatureDialog)
        self.uLatitude.setObjectName(_fromUtf8("uLatitude"))
        self.formLayout.setWidget(4, QtGui.QFormLayout.FieldRole, self.uLatitude)
        self.verticalLayout.addLayout(self.formLayout)
        self.buttonBox = QtGui.QDialogButtonBox(NewFeatureDialog)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.verticalLayout.addWidget(self.buttonBox)

        self.retranslateUi(NewFeatureDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), NewFeatureDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), NewFeatureDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(NewFeatureDialog)

    def retranslateUi(self, NewFeatureDialog):
        NewFeatureDialog.setWindowTitle(QtGui.QApplication.translate("NewFeatureDialog", "Create new feature", None, QtGui.QApplication.UnicodeUTF8))
        self.action_label.setText(QtGui.QApplication.translate("NewFeatureDialog", "Enter name and type of new feature", None, QtGui.QApplication.UnicodeUTF8))
        self.nameLabel.setText(QtGui.QApplication.translate("NewFeatureDialog", "Name", None, QtGui.QApplication.UnicodeUTF8))
        self.lblFeatType.setText(QtGui.QApplication.translate("NewFeatureDialog", "Feature type", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("NewFeatureDialog", "Feature type class", None, QtGui.QApplication.UnicodeUTF8))
        self.label_2.setText(QtGui.QApplication.translate("NewFeatureDialog", "Longitude", None, QtGui.QApplication.UnicodeUTF8))
        self.label_3.setText(QtGui.QApplication.translate("NewFeatureDialog", "Latitude", None, QtGui.QApplication.UnicodeUTF8))


if __name__ == "__main__":
    import sys
    app = QtGui.QApplication(sys.argv)
    NewFeatureDialog = QtGui.QDialog()
    ui = Ui_NewFeatureDialog()
    ui.setupUi(NewFeatureDialog)
    NewFeatureDialog.show()
    sys.exit(app.exec_())

