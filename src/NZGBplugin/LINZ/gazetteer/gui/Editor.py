#!/usr/bin/env python3
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


from __future__ import absolute_import
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *


class Editor(QMainWindow):
    def __init__(self, parent=None):

        # Import delayed to facilitate using as standalone module,
        # Makes setting path before import cleaner.

        from . import DatabaseConfiguration
        from .Controller import Controller
        from .NameSearchWidget import NameSearchDock
        from .NameWebView import NameWebDock

        QMainWindow.__init__(self, parent)
        self._nameDockType = NameWebDock
        self._controller = Controller.instance()
        self._controller.setMainWindow(self)
        self._syscodeWindow = None
        self._helpWindow = None
        self._searchWindow = NameSearchDock()
        self._searchWindow.setFeatures(QDockWidget.NoDockWidgetFeatures)
        self.addDockWidget(Qt.LeftDockWidgetArea, self._searchWindow)
        self._searchWindow.nameSelected.connect(self._controller.showNameId)
        self._controller.nameViewCreated.connect(self.addNameView)
        # if self._controller.database().userIsDba():
        #     self.showAdminWidget()
        self.resize(600, 600)

    def addNameView(self, dock):
        self.tabifyDockWidget(self._searchWindow, dock)

    def showAdminWidget(self):
        dock = self._syscodeWindow
        if not dock:
            from .AdminWidget import AdminWidget

            dock = QDockWidget("System administration", self)
            sce = AdminWidget(dock)
            dock.setWidget(sce)
            dock.setFeatures(QDockWidget.NoDockWidgetFeatures)
            self.tabifyDockWidget(self._searchWindow, dock)
            self._syscodeWindow = dock
        dock.show()
        dock.raise_()

    def showHelp(self, helpfile):
        from PyQt5.QtWebKitWidgets import QWebView

        dock = self._helpWindow
        if not dock:
            dock = QDockWidget("Help", self)
            helpwidget = QWebView(dock)
            url = QUrl.fromLocalFile(helpfile)
            helpwidget.setUrl(url)
            dock.setWidget(helpwidget)
            dock.setFeatures(QDockWidget.NoDockWidgetFeatures)
            self.tabifyDockWidget(self._searchWindow, dock)
            self._helpWindow = url
        dock.show()
        dock.raise_()

    def closeEvent(self, event):
        for c in self.findChildren(self._nameDockType):
            if not c.close():
                event.ignore()
                return
        QMainWindow.closeEvent(self, event)


if __name__ == "__main__":
    import sys
    import getopt
    from os.path import dirname, abspath

    lib = dirname(dirname(dirname(dirname(abspath(__file__)))))
    sys.path.append(lib)
    from . import DatabaseConfiguration

    opts, args = getopt.getopt(sys.argv[1:], "d")
    showSysCodes = False
    for o, a in opts:
        if o == "-d":
            from . import NameWebView

            NameWebView.NameWebView.Debug = True
    app = QApplication([])
    main = Editor()
    if showSysCodes:
        main.showSystemCodeEditor()
    main.show()
    app.exec_()
