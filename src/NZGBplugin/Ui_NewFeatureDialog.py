# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Ui_NewFeatureDialog.ui'
#
# Created by: PyQt5 UI code generator 5.14.1
#
# WARNING! All changes made in this file will be lost!


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_NewFeatureDialog(object):
    def setupUi(self, NewFeatureDialog):
        NewFeatureDialog.setObjectName("NewFeatureDialog")
        NewFeatureDialog.setWindowModality(QtCore.Qt.ApplicationModal)
        NewFeatureDialog.resize(517, 223)
        NewFeatureDialog.setModal(True)
        self.verticalLayout = QtWidgets.QVBoxLayout(NewFeatureDialog)
        self.verticalLayout.setObjectName("verticalLayout")
        self.action_label = QtWidgets.QLabel(NewFeatureDialog)
        self.action_label.setObjectName("action_label")
        self.verticalLayout.addWidget(self.action_label)
        self.formLayout = QtWidgets.QFormLayout()
        self.formLayout.setLabelAlignment(
            QtCore.Qt.AlignLeading | QtCore.Qt.AlignLeft | QtCore.Qt.AlignTop
        )
        self.formLayout.setFormAlignment(
            QtCore.Qt.AlignLeading | QtCore.Qt.AlignLeft | QtCore.Qt.AlignVCenter
        )
        self.formLayout.setObjectName("formLayout")
        self.nameLabel = QtWidgets.QLabel(NewFeatureDialog)
        self.nameLabel.setObjectName("nameLabel")
        self.formLayout.setWidget(0, QtWidgets.QFormLayout.LabelRole, self.nameLabel)
        self.lblFeatType = QtWidgets.QLabel(NewFeatureDialog)
        self.lblFeatType.setObjectName("lblFeatType")
        self.formLayout.setWidget(2, QtWidgets.QFormLayout.LabelRole, self.lblFeatType)
        self.uFeatName = QtWidgets.QLineEdit(NewFeatureDialog)
        self.uFeatName.setObjectName("uFeatName")
        self.formLayout.setWidget(0, QtWidgets.QFormLayout.FieldRole, self.uFeatName)
        self.uFeatType = QtWidgets.QComboBox(NewFeatureDialog)
        self.uFeatType.setObjectName("uFeatType")
        self.formLayout.setWidget(2, QtWidgets.QFormLayout.FieldRole, self.uFeatType)
        self.label = QtWidgets.QLabel(NewFeatureDialog)
        self.label.setObjectName("label")
        self.formLayout.setWidget(1, QtWidgets.QFormLayout.LabelRole, self.label)
        self.uFeatTypeClass = QtWidgets.QComboBox(NewFeatureDialog)
        self.uFeatTypeClass.setObjectName("uFeatTypeClass")
        self.formLayout.setWidget(
            1, QtWidgets.QFormLayout.FieldRole, self.uFeatTypeClass
        )
        self.uLongitude = QtWidgets.QLineEdit(NewFeatureDialog)
        self.uLongitude.setObjectName("uLongitude")
        self.formLayout.setWidget(3, QtWidgets.QFormLayout.FieldRole, self.uLongitude)
        self.label_2 = QtWidgets.QLabel(NewFeatureDialog)
        self.label_2.setObjectName("label_2")
        self.formLayout.setWidget(3, QtWidgets.QFormLayout.LabelRole, self.label_2)
        self.label_3 = QtWidgets.QLabel(NewFeatureDialog)
        self.label_3.setObjectName("label_3")
        self.formLayout.setWidget(4, QtWidgets.QFormLayout.LabelRole, self.label_3)
        self.uLatitude = QtWidgets.QLineEdit(NewFeatureDialog)
        self.uLatitude.setObjectName("uLatitude")
        self.formLayout.setWidget(4, QtWidgets.QFormLayout.FieldRole, self.uLatitude)
        self.verticalLayout.addLayout(self.formLayout)
        self.buttonBox = QtWidgets.QDialogButtonBox(NewFeatureDialog)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(
            QtWidgets.QDialogButtonBox.Cancel | QtWidgets.QDialogButtonBox.Ok
        )
        self.buttonBox.setObjectName("buttonBox")
        self.verticalLayout.addWidget(self.buttonBox)

        self.retranslateUi(NewFeatureDialog)
        self.buttonBox.accepted.connect(NewFeatureDialog.accept)
        self.buttonBox.rejected.connect(NewFeatureDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(NewFeatureDialog)

    def retranslateUi(self, NewFeatureDialog):
        _translate = QtCore.QCoreApplication.translate
        NewFeatureDialog.setWindowTitle(
            _translate("NewFeatureDialog", "Create new feature")
        )
        self.action_label.setText(
            _translate("NewFeatureDialog", "Enter name and type of new feature")
        )
        self.nameLabel.setText(_translate("NewFeatureDialog", "Name"))
        self.lblFeatType.setText(_translate("NewFeatureDialog", "Feature type"))
        self.label.setText(_translate("NewFeatureDialog", "Feature type class"))
        self.label_2.setText(_translate("NewFeatureDialog", "Longitude"))
        self.label_3.setText(_translate("NewFeatureDialog", "Latitude"))
