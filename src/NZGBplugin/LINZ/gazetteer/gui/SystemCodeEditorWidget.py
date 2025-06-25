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

if __name__ == "__main__":
    import sys
    from os.path import dirname, abspath

    lib = dirname(dirname(dirname(dirname(abspath(__file__)))))
    sys.path.append(lib)

import os
from qgis.PyQt import uic
from qgis.PyQt.QtWidgets import QWidget, QMessageBox, QApplication, QDialog, QVBoxLayout

# Import controller before model components to ensure database is configured..

from .Controller import Controller
from LINZ.gazetteer.Model import SystemCode
from LINZ.Widgets import QtUtils
from LINZ.Widgets.ListModelConnector import ListModelConnector
from LINZ.Widgets.SqlAlchemyAdaptor import SqlAlchemyAdaptor
from LINZ.Widgets.UCaseRegExpValidator import UCaseRegExpValidator

UI_SYSTEM_CODE_EDITOR_WIDGET, _ = uic.loadUiType(
    os.path.join(os.path.dirname(__file__), "Ui_SystemCodeEditorWidget.ui")
)


class SystemCodeEditorWidget(UI_SYSTEM_CODE_EDITOR_WIDGET, QWidget):
    def __init__(self, parent=None, userOnly=True):
        QWidget.__init__(self, parent)
        self._controller = Controller.instance()
        self._database = self._controller.database()
        self.setupUi(self)
        self._group = None
        self._loadCodeOnSelect = True
        self.populateSystemCodes(userOnly)
        adaptor = SqlAlchemyAdaptor(SystemCode)
        model = ListModelConnector(
            adaptor=adaptor,
            columns=["code", "category", "value", "description"],
            idColumn="code",
        )
        self.uCodesTable.setModel(model)

        self.uCodeEditor.setAdaptor(adaptor, "code_", "system code")
        self.uCodeEditor.addValidator(
            "code",
            UCaseRegExpValidator(r"\w{4}"),
            "The code must be a four character string",
        )
        self.uCodeEditor.addValidator(
            "code",
            self.checkCodeIsUnique,
            "Invalid code: The code entered is already defined",
        )
        self.uCodeEditor.addValidator("value", r"\S.*", "The value cannot be empty")
        self.uCodeEditor.loaded.connect(self.codeLoaded)
        self.uCodeEditor.saved.connect(self.codeSaved)
        self.uCodeEditor.cancelled.connect(self.codeCancelled)

        self.uCodeGroupSelector.currentIndexChanged[int].connect(
            lambda x: self.selectCodeGroup()
        )
        self.uCodesTable.rowSelected.connect(self.codeSelected)
        self.uDeleteCodeButton.clicked.connect(self.deleteCode)
        self.uNewCodeButton.clicked.connect(self.newCode)
        self.uCodeGroupSelector.setCurrentIndex(0)

    def populateSystemCodes(self, userOnly):
        query = self._database.query(SystemCode).filter(SystemCode.code_group == "CODE")
        if userOnly:
            query = query.filter(SystemCode.category == "USER")
        codeGroups = query.order_by(SystemCode.code).all()
        self.uCodeGroupSelector.populate(
            codeGroups, display=lambda x: x.code + ": " + x.value
        )

    def selectedCodeGroup(self):
        return self.uCodeGroupSelector.selectedItem()

    def setSelectedCodeGroup(self, group):
        self.uCodeGroupSelector.setSelectedItem(self._group)

    def reselectCodeGroup(self):
        try:
            self._loadCodeOnSelect = False
            self.setSelectedCodeGroup(self._group)
        finally:
            self._loadCodeOnSelect = True

    def selectCodeGroup(self):
        # Populate the categories drop down in the details field
        group = self.selectedCodeGroup()
        if group == self._group:
            return
        # Need to set selected row to null instead ...
        if not self.uCodeEditor.querySave():
            self.reselectCodeGroup()
            return
        self.uCodesTable.clearSelection()
        categories = []
        self._group = group
        if group:
            category = SystemCode.codeGroupCategory(group.code)
            if category:
                mapping = SystemCode.codeMapping(category, refresh=True)
                categories = [(k, mapping[k]) for k in list(mapping.keys())]
                categories.sort(key=lambda x: x[1])
        QtUtils.populateCombo(self.code_category, categories)
        self.code_category.setEnabled(len(categories) > 0)
        self.populateCodeList()

    def populateCodeList(self, code=None):
        code_group = self.selectedCodeGroup()
        self.uNewCodeButton.setEnabled(code_group is not None)
        if not code_group:
            self.uCodesTable.setList([])
        else:
            query = (
                self._database.query(SystemCode)
                .filter(SystemCode.code_group == code_group.code)
                .order_by(SystemCode.code)
            )
            codes = query.all()
            self.uCodesTable.setList(codes)
            if code:
                self.uCodesTable.selectId(code.code)

    def codeSelected(self, row):
        if self._loadCodeOnSelect:
            self.loadCode()
        self.uDeleteCodeButton.setEnabled(self.selectedCode() is not None)

    def selectedCode(self):
        return self.uCodesTable.selectedItem()

    def loadCode(self, overwrite=False):
        code = self.selectedCode()
        self.uCodeEditor.load(code, overwrite=overwrite)

    def codeLoaded(self, code):
        self.code_code.setEnabled(self.uCodeEditor.isNew())

    def codeSaved(self, code):
        try:
            self._database.add(code)
            self._database.commit()
            self.populateCodeList(code)
        except Exception as e:
            QMessageBox.warning(self, "Error saving code", e.message)

    def codeCancelled(self):
        self.loadCode(overwrite=True)

    def newCode(self):
        if not self.uCodeEditor.querySave():
            return
        code = SystemCode()
        code.code_group = self.selectedCodeGroup().code
        self.uCodeEditor.load(code, isNew=True, overwrite=True)

    def deleteCode(self):
        code = self.selectedCode()
        try:
            if not code.canBeDeleted():
                raise RuntimeError("This code is in use - it cannot be deleted")
            self._database.delete(code)
            self._database.commit()
            self.populateCodeList()
        except Exception as e:
            QMessageBox.warning(self, "Error deleting code", e.message)

    def checkCodeIsUnique(self):
        if not self.uCodeEditor.isNew():
            return True
        code = str(self.code_code.text())
        for c in self.uCodesTable.list():
            if c.code == code:
                return False
        return True


if __name__ == "__main__":
    app = QApplication([])
    dlg = QDialog()
    layout = QVBoxLayout()
    layout.addWidget(SystemCodeEditorWidget(userOnly="-s" not in sys.argv))
    dlg.setLayout(layout)
    dlg.show()
    app.exec_()
