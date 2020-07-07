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
from builtins import object
import sys
import os.path
import configparser

from PyQt5.QtGui import *
from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from qgis.core import *

from qgis.gui import QgsMapToolEmitPoint

from . import Resources
from .SelectNameTool import SelectNameTool


class Plugin(object):

    file_path = os.path.join(os.path.dirname(__file__), "metadata.txt")
    parser = configparser.ConfigParser()
    parser.read(file_path)

    Version = parser["general"]["Version"]
    Name = parser["general"]["Name"]
    _menuName = "Gazetteer editor"

    def __init__(self, iface):
        self._iface = iface
        self._statusBar = iface.mainWindow().statusBar()
        self._editor = None
        self._editorDock = None
        self._layers = None
        self._controller = None
        self._selectptr = None
        self._maptool = None

    def initGui(self):

        self._runaction = QAction(
            QIcon(":/plugins/GazetteerEditor/icon.png"),
            "Open the gazetteer editor",
            self._iface.mainWindow(),
        )
        self._runaction.setWhatsThis("Open the gazetteer editor window")
        self._runaction.triggered.connect(self._run)

        # self._helpaction = QAction(QIcon(":/plugins/GazetteerEditor/help.png"),
        #     "Help on gazetter application", self._iface.mainWindow())
        # self._helpaction.setWhatsThis("Help on using the gazetteer application")
        # self._helpaction.setEnabled( True )
        # self._helpaction.triggered.connect( self._showHelp )

        self._infoaction = QAction(
            QIcon(":/plugins/GazetteerEditor/help.png"),
            "About gazetteer application",
            self._iface.mainWindow(),
        )
        self._infoaction.setWhatsThis("Information on gazetteer application settings")
        self._infoaction.setEnabled(True)
        self._infoaction.triggered.connect(self._showInfo)

        self._adminaction = QAction(
            QIcon(":/plugins/GazetteerEditor/admin.png"),
            "Administration functions",
            self._iface.mainWindow(),
        )
        self._adminaction.setWhatsThis("Update the web database, administer users, etc")
        self._adminaction.setEnabled(True)
        self._adminaction.triggered.connect(self._runAdmin)

        self._ptraction = QAction(
            QIcon(":/plugins/GazetteerEditor/searchpointer.png"),
            "Identify/select search result",
            self._iface.mainWindow(),
        )
        self._ptraction.setWhatsThis(
            "Identify/select gazetteer search results on the map"
        )
        self._ptraction.setEnabled(False)
        self._ptraction.triggered.connect(self._activateSelectTool)

        self._addselaction = QAction(
            QIcon(":/plugins/GazetteerEditor/addselected.png"),
            "Add selected geometries to feature",
            self._iface.mainWindow(),
        )
        self._addselaction.setWhatsThis("Add selected geometries to current feature")
        self._addselaction.setEnabled(False)
        self._addselaction.triggered.connect(self._addSelectedGeometries)

        self._delselaction = QAction(
            QIcon(":/plugins/GazetteerEditor/delselected.png"),
            "Remove selected geometries from feature",
            self._iface.mainWindow(),
        )
        self._delselaction.setWhatsThis(
            "Remove selected geometries from current feature"
        )
        self._delselaction.setEnabled(False)
        self._delselaction.triggered.connect(self._deleteSelectedGeometries)

        iface = self._iface

        self._editshift = QAction(
            QIcon(":/plugins/GazetteerEditor/editshift.png"),
            "Move feature geometries",
            self._iface.mainWindow(),
        )
        self._editshift.setWhatsThis("Shift the geometries of the current feature")
        self._editshift.setEnabled(False)
        self._editshift.triggered.connect(
            lambda: self._editGeometries(False, iface.actionVertexTool())
        )

        self._editnodes = QAction(
            QIcon(":/plugins/GazetteerEditor/editnodes.png"),
            "Move feature geometry nodes",
            self._iface.mainWindow(),
        )
        self._editnodes.setWhatsThis(
            "Edit the nodes of the geometries of the current feature"
        )
        self._editnodes.setEnabled(False)
        self._editnodes.triggered.connect(
            lambda: self._editGeometries(False, iface.actionNodeTool())
        )

        self._editnew = QAction(
            QIcon(":/plugins/GazetteerEditor/editnew.png"),
            "New feature geometries",
            self._iface.mainWindow(),
        )
        self._editnew.setWhatsThis("Create new geometries for the feature")
        self._editnew.setEnabled(False)
        self._editnew.triggered.connect(
            lambda: self._editGeometries(True, iface.actionAddFeature())
        )

        self._editsave = QAction(
            QIcon(":/plugins/GazetteerEditor/editsave.png"),
            "Save feature geometry edits",
            self._iface.mainWindow(),
        )
        self._editsave.setWhatsThis("Save changes to the feature geometries")
        self._editsave.setEnabled(False)
        self._editsave.triggered.connect(lambda: self._layers.endFeatureEdits(False))

        self._editcancel = QAction(
            QIcon(":/plugins/GazetteerEditor/editcancel.png"),
            "Discard feature geometry edits",
            self._iface.mainWindow(),
        )
        self._editcancel.setWhatsThis("Discard changes to the feature geometries")
        self._editcancel.setEnabled(False)
        self._editcancel.triggered.connect(lambda: self._layers.endFeatureEdits(True))

        self._newfeat = QAction(
            QIcon(":/plugins/GazetteerEditor/newfeat.png"),
            "Create a new feature",
            self._iface.mainWindow(),
        )
        self._newfeat.setWhatsThis("Create a new feature at a selected location")
        self._newfeat.setEnabled(False)
        self._newfeat.triggered.connect(self._createNewFeature)

        self._toolbar = self._iface.addToolBar("Gazetteer tools")
        self._toolbar.addAction(self._runaction)
        # self._toolbar.addAction( self._helpaction )
        self._toolbar.addAction(self._ptraction)
        self._toolbar.addAction(self._editshift)
        self._toolbar.addAction(self._editnodes)
        self._toolbar.addAction(self._editnew)
        self._toolbar.addAction(self._addselaction)
        self._toolbar.addAction(self._delselaction)
        self._toolbar.addAction(self._editsave)
        self._toolbar.addAction(self._editcancel)
        self._toolbar.addAction(self._newfeat)

        self._currNameLabel = QLineEdit(self._toolbar)
        self._currNameLabel.setReadOnly(True)
        self._toolbar.addWidget(self._currNameLabel)

        self._iface.addPluginToMenu(self._menuName, self._runaction)
        self._iface.addPluginToMenu(self._menuName, self._adminaction)
        # self._iface.addPluginToMenu(self._menuName, self._helpaction)
        self._iface.addPluginToMenu(self._menuName, self._infoaction)

    def unload(self):
        self._toolbar = self._iface.mainWindow().removeToolBar(self._toolbar)
        self._iface.removePluginMenu(self._menuName, self._adminaction)
        self._iface.removePluginMenu(self._menuName, self._runaction)
        # self._iface.removePluginMenu(self._menuName,self._helpaction)
        self._iface.removePluginMenu(self._menuName, self._infoaction)

    def _createEditor(self):
        if self._editorDock:
            return

        main = self._iface.mainWindow()

        if not self._editor:
            sys.path.insert(0, os.path.dirname(__file__))
            from .LINZ.gazetteer.gui.Controller import Controller

            self._controller = Controller.instance()
            # Check if user is valid - will raise exception if not
            dbinstance = self._controller.database().instance()

            # Check version of application
            version = self._controller.database().scalar(
                "select value from system_code where code_group='APSD' and code='VRSN'"
            )

            if version != self.Version:
                result = QMessageBox.question(
                    self._iface.mainWindow(),
                    "Application version error",
                    "You are using version "
                    + self.Version
                    + " of the gazetteer plugin,\n"
                    "but the current version is " + version + "\n\n"
                    "Do you want to continue with this version?",
                    QMessageBox.Yes | QMessageBox.No,
                )
                if result != QMessageBox.Yes:
                    return

            from .LINZ.gazetteer.gui.Editor import Editor
            from . import Layers

            self._editor = Editor(self._iface.mainWindow())
            self._newfeat.setEnabled(True)
            self._layers = Layers.Layers(self._iface)
            self._layers.startEdit.connect(lambda: self._setEditing(True))
            self._layers.endEdit.connect(lambda: self._setEditing(False))
            self._layers.nameSelected.connect(self._currNameLabel.setText)
            self._selectptr = SelectNameTool(self._iface, self._layers)
            self._controller.searchResultsUpdated.connect(self._searchResultsUpdated)
            self._controller.viewNameId.connect(self._viewName)
            helpfile = os.path.join(os.path.dirname(__file__), "help", "index.html")
            if os.path.exists(helpfile):
                self._editor.showHelp(helpfile)

        dock = QDockWidget()
        dock.setFloating(False)
        dock.setWindowTitle("Gazetteer editor")
        dock.setObjectName("GazetteerEditor")
        dock.setWidget(self._editor)
        main.addDockWidget(Qt.RightDockWidgetArea, dock)
        self._editorDock = dock

    def _run(self):
        if not self._editorDock:
            try:
                self._createEditor()
            except:
                message = str(sys.exc_info()[1])
                QMessageBox.warning(
                    self._iface.mainWindow(), "Gazetteer application error", message
                )
            if not self._editorDock:
                return

        self._editorDock.show()
        self._editorDock.showNormal()
        self._editorDock.setFloating(False)

    #        if self._editorDock.isFloating():
    #            if self._editorDock.isMinimized():
    #                self._editorDock.showNormal()
    #            self._editorDock.show()
    #            self._editorDock.raise_()

    def _runAdmin(self):
        self._run()
        if not self._editorDock:
            return
        if not self._controller.database().userIsDba():
            QMessageBox.warning(
                self._iface.mainWindow(),
                "Gazetter authorization error",
                "You are not authorised to run gazetteer administration functions",
            )
            return
        from .LINZ.gazetteer.gui.AdminWidget import AdminDialog

        dlg = AdminDialog(self._iface.mainWindow())
        dlg.exec_()

    def _searchResultsUpdated(self, idString):
        self._ptraction.setEnabled(idString != "")

    def _viewName(self, id):
        self._addselaction.setEnabled(True)
        self._delselaction.setEnabled(True)
        self._editshift.setEnabled(True)
        self._editnodes.setEnabled(True)
        self._editnew.setEnabled(True)

    def _editGeometries(self, addNew, action):
        self._layers.startFeatureEdits(addNew)
        action.trigger()

    def _setEditing(self, editing):
        self._editsave.setEnabled(editing)
        self._editcancel.setEnabled(editing)

    def _activateSelectTool(self):
        if self._selectptr:
            self._iface.mapCanvas().setMapTool(self._selectptr)

    def _addSelectedGeometries(self):
        self._layers.addSelectedGeometries()

    def _deleteSelectedGeometries(self):
        self._layers.deleteSelectedGeometries()

    def _createNewFeature(self):
        if not self._layers.endFeatureEdits():
            return
        self._statusBar.showMessage("Click map to create a new gazetteer feature")
        canvas = self._iface.mapCanvas()
        if not self._maptool:
            self._maptool = QgsMapToolEmitPoint(canvas)
            self._maptool.canvasClicked.connect(self._newFeaturePointSelected)
        canvas.setMapTool(self._maptool)

    def _newFeaturePointSelected(self, point, button):
        point = self._layers.transformMapPoint(point)
        if point.x() < 0:
            point.setX(point.x() + 360)
        if point.x() > 360 or point.y() < -90 or point.y() > 90:
            self._iface.messageBar().pushMessage(
                "Gazetter location error",
                "The location selected for the new feature is not at a valid latitude and longitude",
                level=Qgis.Critical,
                duration=10,
            )
            return

        from .NewFeatureDialog import NewFeatureDialog

        NewFeatureDialog.createNewFeature(
            point.x(), point.y(), self._controller, self._iface
        )

    def _showInfo(self):
        about = [
            "Application: {0}".format(self.Name),
            "Version: {0}".format(self.Version),
        ]
        if self._controller:
            conn = self._controller.databaseConfiguration()
            about.extend(
                [
                    "Database host: {0}".format(conn.get("host") or ""),
                    "Database name: {0}".format(conn.get("database") or ""),
                    "Database user: {0}".format(conn.get("user") or ""),
                ]
            )
        else:
            about.extend(["Database: not connected !"])
        QMessageBox.information(self._iface.mainWindow(), "About", "\n".join(about))

    def _showHelp(self):
        file = "file://" + os.path.join(os.path.dirname(__file__), "help", "index.html")
        file = file.replace("\\", "/")
        self._iface.openURL(file, False)
