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


from builtins import str
import sys

from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *

from LINZ.Widgets import QtUtils
from LINZ.Widgets.ListModelConnector import ListModelConnector
from LINZ.Widgets.DictionaryAdaptor import DictionaryAdaptor
from LINZ.Widgets.UCaseRegExpValidator import UCaseRegExpValidator
from LINZ.Widgets.ValidatorList import ValidatorList
from LINZ.Widgets.WidgetConnector import WidgetConnector
from LINZ.Widgets.ErrorHandler import handleException

from . import DatabaseConfiguration
from LINZ.gazetteer.Model import Name
from . import FormUtils
from LINZ.gazetteer.Model import SystemCode

from . import FormUtils
from .Ui_NameSearchWidget import Ui_NameSearchWidget

from .Controller import Controller


class NameSearchWidget(QWidget, Ui_NameSearchWidget):
    nameSelected = pyqtSignal(int, bool, name="nameSelected")

    def __init__(self, parent=None, userOnly=True):
        QWidget.__init__(self, parent)
        self.setupUi(self)
        self._setAdvanced(False)
        self._searchDef = None
        self._mapExtents = None
        self._keyState = Qt.NoModifier
        self._controller = Controller.instance()
        self._applyMapExtents()
        self._adaptor = DictionaryAdaptor("name", "name_status", "feat_type")
        self.uSearchResults.setTabKeyNavigation(False)
        self._populateDropDownLists()
        self.uSearchText.installEventFilter(self)
        self.uSearchResults.installEventFilter(self)
        self.uToggleAdvanced.clicked.connect(
            lambda: self._setAdvanced(not self._advanced)
        )
        self.uSearchButton.clicked.connect(self._doSearch)
        self.uClearSearch.clicked.connect(lambda: self._doSearch(True))
        self.uSearchResults.clicked.connect(
            lambda i: self._selectResult(self.uSearchResults, i)
        )
        self.uRecentNames.clicked.connect(
            lambda i: self._selectResult(self.uRecentNames, i)
        )
        self.uFavourites.clicked.connect(
            lambda i: self._selectResult(self.uFavourites, i)
        )
        self.uAllUsers.toggled.connect(self._populateRecent)
        self.uEditOnly.toggled.connect(self._populateRecent)
        self.uMaxRecent.valueChanged.connect(lambda x: self._populateRecent)
        self.tabs.currentChanged.connect(self._populateTabList)
        self._controller.recentUpdated.connect(self._populateRecent)
        self._controller.nameEdited.connect(self._clearSearchDef)
        self._controller.favouritesUpdated.connect(self._populateFavourites)
        self._controller.mapExtentsChanged.connect(self._applyMapExtents)

    def _setAdvanced(self, status):
        if status:
            self.uSearchAdvanced.show()
            self.uToggleAdvanced.setText("Simple")
            self._advanced = True
        else:
            self.uSearchAdvanced.hide()
            self.uToggleAdvanced.setText("Advanced")
            self._advanced = False

    def _populateDropDownLists(self):
        codes = SystemCode.codeGroup("NSTS")
        official = " ".join([c.code for c in codes if c.category == "OFFC"])
        unofficial = " ".join([c.code for c in codes if c.category == "UOFC"])
        unpublished = " ".join([c.code for c in codes if c.category == "NPUB"])
        FormUtils.populateCodeCombo(
            self.uSearchNameStatus,
            "NSTS",
            True,
            [
                (official, "(Official)"),
                (unofficial, "(Unofficial)"),
                (unpublished, "(Unpublished)"),
            ],
        )
        FormUtils.populateCodeCombo(self.uSearchFeatClass, "FCLS", True)
        self.uSearchFeatClass.currentIndexChanged.connect(
            self._populateFeatTypeDropdown
        )

    def _populateFeatTypeDropdown(self, index):
        fclass = QtUtils.comboValue(self.uSearchFeatClass)
        if fclass:
            FormUtils.populateCodeCombo(
                self.uSearchFeatType, "FTYP", True, category=str(fclass)
            )
        else:
            self.uSearchFeatType.clear()

    def _clearSearchDef(self):
        self._searchDef = None

    def _doSearch(self, clear=False):
        text = ""
        if not clear:
            text = str(self.uSearchText.text())
        feat_type = None
        name_status = None
        not_pub = False
        extents = None
        maxResults = 100
        if self._advanced and not clear:
            feat_type = None
            fclass = QtUtils.comboValue(self.uSearchFeatClass)
            if fclass:
                feat_type = QtUtils.comboValue(self.uSearchFeatType)
                if feat_type:
                    feat_type = str(feat_type)
                else:
                    codes = SystemCode.codeGroup("FTYP")
                    feat_type = " ".join(
                        c.code for c in codes if c.category == str(fclass)
                    )
            name_status = QtUtils.comboValue(self.uSearchNameStatus)
            name_status = str(name_status) if name_status else None
            not_pub = self.uSearchUnpublished.isChecked()
            maxResults = self.uSearchMaxResults.value()
            if self.uSearchMapExtent.isChecked():
                extents = self._controller.mapExtentsNZGD2000()

        searchDef = {
            "text": text,
            "feat_type": feat_type,
            "name_status": name_status,
            "not_pub": not_pub,
            "extents": extents,
            "maxResults": maxResults,
        }

        if searchDef == self._searchDef:
            return
        try:
            self._searchDef = searchDef
            results = []
            if not clear:
                if self._advanced:
                    results = Name.search2(
                        name=text,
                        ftype=feat_type,
                        status=name_status,
                        notpublished=not_pub,
                        extentWkt=extents,
                        maxresults=maxResults,
                    )
                elif text:
                    results = Name.search(name=text, maxresults=maxResults)

            self._populateResultList(self.uSearchResults, results)
            self._controller.setSearchResults(results)
            if not clear:
                status = (
                    str(len(results))
                    + " match"
                    + ("es" if len(results) == 1 else "")
                    + " found"
                )
                if len(results) > 0:
                    status += ". Click name to open, Shift+Click to open in new window"
                self.uSearchStatus.setText(status)
        except:
            self._populateResultList(self.uSearchResults, [])
            self._controller.setSearchResults([])
            msg = str(sys.exc_info()[1])
            QMessageBox.information(self, "Search error", msg)
            self.uSearchStatus.setText(msg)

    def _applyMapExtents(self):
        self._mapExtents = self._controller.mapExtentsNZGD2000()
        if self._mapExtents:
            self.uSearchMapExtent.show()
        else:
            self.uSearchMapExtent.hide()

    def _populateTabList(self):
        if self.tabs.currentWidget() == self.tabFavourites:
            self._populateFavourites()
        elif self.tabs.currentWidget() == self.tabRecent:
            self._populateRecent()

    def _populateFavourites(self):
        if self.tabs.currentWidget() == self.tabFavourites:
            self._populateResultList(self.uFavourites, self._controller.favourites())

    def _populateRecent(self):
        if self.tabs.currentWidget() != self.tabRecent:
            return
        allusers = True if self.uAllUsers.isChecked() else False
        editonly = True if self.uEditOnly.isChecked() else False
        nmax = self.uMaxRecent.value()
        self._populateResultList(
            self.uRecentNames, self._controller.recent(allusers, editonly, nmax)
        )

    def _populateResultList(self, listCtl, resultSet):
        results = []
        ftypes = {}
        for c in SystemCode.codeGroup("FTYP"):
            ftypes[c.code] = (
                c.value + " (" + SystemCode.lookup("FCLS", c.category, "") + ")"
            )
        try:
            for row in resultSet:
                r = dict()
                r["name_id"] = row.name_id
                r["name"] = row.name
                r["name_status"] = SystemCode.lookup("NSTS", row.name_status)
                r["feat_type"] = ftypes.get(row.feat_type)
                results.append(r)
        except:
            handleException()
            results = []
        listCtl.setList(
            results,
            adaptor=self._adaptor,
            columns=["name", "name_status", "feat_type"],
            headers=["Name", "Status", "Feature Type"],
        )
        listCtl.clearSelection()

    def eventFilter(self, widget, event):
        if event.type() == QEvent.KeyPress:
            if widget == self.uSearchText and event.key() in [
                Qt.Key_Down,
                Qt.Key_Enter,
                Qt.Key_Return,
            ]:
                self._doSearch()
                if self.uSearchResults.rowCount() > 0:
                    self.uSearchResults.selectRow(0)
                    self.uSearchResults.setFocus()
                    return True
            elif widget == self.uSearchResults:
                if event.key() == Qt.Key_Up:
                    if not self.uSearchResults.selectedRow():
                        self.uSearchText.setFocus()
                        return True
                elif event.key() in [Qt.Key_Enter, Qt.Key_Return]:
                    selected = self.uSearchResults.selectedItem()
                    if selected:
                        self._selectNameId(selected["name_id"])
        return False

    def _selectResult(self, sender, index):
        item = sender.itemAt(index.row())
        self._selectNameId(item["name_id"])

    def _selectNameId(self, name_id):
        self.nameSelected.emit(
            name_id,
            (QApplication.keyboardModifiers() & Qt.ShiftModifier) == Qt.ShiftModifier,
        )


class NameSearchDock(QDockWidget):
    nameSelected = pyqtSignal(int, int, name="nameSelected")

    def __init__(self, parent=None):
        QDockWidget.__init__(self, "Search", parent)
        searchWidget = NameSearchWidget(self)
        self.setWidget(searchWidget)
        searchWidget.nameSelected.connect(self.nameSelected.emit)


if __name__ == "__main__":
    app = QApplication([])
    dlg = QDialog()
    layout = QVBoxLayout()
    widget = NameSearchWidget()
    layout.addWidget(widget)

    def printit(x):
        # fix_print_with_import
        print(x)

    widget.nameSelected.connect(lambda x, i: printit(x))
    dlg.setLayout(layout)
    dlg.show()
    app.exec_()
