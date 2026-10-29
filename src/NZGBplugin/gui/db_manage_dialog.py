from typing import Optional
from functools import partial

from qgis.PyQt.QtCore import QObject, Qt, QModelIndex, QItemSelectionModel
from qgis.PyQt.QtWidgets import (
    QDialog,
    QWidget,
    QGridLayout,
    QDialogButtonBox,
    QLabel,
    QMenu,
)
from qgis.core import Qgis, QgsBrowserProxyModel
from qgis.gui import QgsBrowserTreeView, QgsGui, QgsDataItemGuiContext
from qgis.utils import iface


class DbConnectionOnlyProxyModel(QgsBrowserProxyModel):
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self.setShownDataItemProviderKeyFilter(["PostGIS"])

    def hasChildren(self, parent=QModelIndex()):
        # only want root item and connections to be expandable, not individual schema
        data_item = self.browserModel().dataItem(self.mapToSource(parent))
        if not data_item:
            return True

        path_parts = data_item.path().split("/")
        return len(path_parts) <= 2

    def flags(self, index):
        data_item = self.browserModel().dataItem(self.mapToSource(index))
        flags = super().flags(index)
        path_parts = data_item.path().split("/")
        if len(path_parts) <= 2:
            # don't allow root item or connection item to be selected
            flags = Qt.ItemIsEnabled

        return flags

    def filterAcceptsRow(self, source_row, source_parent_index):
        if not super().filterAcceptsRow(source_row, source_parent_index):
            return False

        source_index = self.browserModel().index(source_row, 0, source_parent_index)
        data_item = self.browserModel().dataItem(source_index)

        # only want root item, connection items and schemas, not tables
        path_parts = data_item.path().split("/")
        return len(path_parts) <= 3


class DbManagerDialog(QDialog):
    def __init__(self, parent: Optional[QWidget] = None):
        super().__init__(parent)
        self.setObjectName("DbManagerDialog")
        QgsGui.enableAutoGeometryRestore(self)

        gl = QGridLayout()

        gl.addWidget(QLabel("Select database connection and schema:"), 0, 0, 1, 1)

        self.browser_model = iface.browserModel()

        self.proxy_model = DbConnectionOnlyProxyModel(self)
        self.proxy_model.setBrowserModel(self.browser_model)
        self.browser_view = QgsBrowserTreeView()
        self.browser_view.setBrowserModel(self.browser_model)
        self.browser_view.setModel(self.proxy_model)
        self.browser_view.setHeaderHidden(True)

        pg_root_item_index = self.browser_model.findPath("pg:")
        self.browser_view.expand(self.proxy_model.mapFromSource(pg_root_item_index))

        gl.addWidget(self.browser_view, 1, 0, 1, 1)

        self.button_box = QDialogButtonBox()
        self.button_box.setStandardButtons(
            QDialogButtonBox.Ok | QDialogButtonBox.Cancel
        )
        self.create_button = self.button_box.addButton(
            "Create Connection", QDialogButtonBox.ActionRole
        )
        self.button_box.accepted.connect(self.accept)
        self.button_box.rejected.connect(self.reject)
        self.button_box.button(QDialogButtonBox.Ok).setEnabled(False)
        self.create_button.clicked.connect(self._create_connection)

        gl.addWidget(self.button_box, 2, 0, 1, 1)

        self.setLayout(gl)

        self.browser_view.selectionModel().selectionChanged.connect(
            self._selected_items_changed
        )

    def _selected_items_changed(self, selected, deselected):
        has_selection = len(selected.indexes()) > 0
        self.button_box.button(QDialogButtonBox.Ok).setEnabled(has_selection)

    def _create_connection(self):
        # QgsPgNewConnection not exposed to Python, so use a workaround to show it
        pg_root_item_index = self.browser_model.findPath("pg:")

        pg_data_item_gui_provider = QgsGui.providerGuiRegistry().dataItemGuiProviders(
            "postgres"
        )[0]

        menu = QMenu()
        context = QgsDataItemGuiContext()
        pg_data_item_gui_provider.populateContextMenu(
            self.browser_model.dataItem(pg_root_item_index), menu, [], context
        )

        new_connection_action = [a for a in menu.actions() if "New" in a.text()]
        if not new_connection_action:
            new_connection_action = menu.actions()[0]
        else:
            new_connection_action = new_connection_action[0]

        new_connection_action.trigger()

        self.show()
        self.raise_()
        self.activateWindow()

    def set_selected_connection_details(
        self, name: Optional[str], schema: Optional[str]
    ):
        """
        Sets the selected connection name and schema
        """
        if not name:
            self.browser_view.selectionModel().clear()
        else:
            item_index = self.browser_model.findPath(f"pg:/{name}")
            if item_index.isValid():
                connection_item = self.browser_model.dataItem(item_index)
                proxy_index = self.proxy_model.mapFromSource(item_index)
                self.browser_view.selectionModel().select(
                    proxy_index, QItemSelectionModel.ClearAndSelect
                )
                self.browser_view.expand(proxy_index)
                if connection_item.state() == Qgis.BrowserItemState.Populated:
                    schema_item_index = self.browser_model.findPath(
                        f"pg:/{name}/{schema}"
                    )
                    self.browser_view.selectionModel().select(
                        self.proxy_model.mapFromSource(schema_item_index),
                        QItemSelectionModel.ClearAndSelect,
                    )
                else:
                    # when schemas have populated, select the stored schema name
                    self.browser_model.rowsInserted.connect(
                        partial(self._rows_added, item_index, schema)
                    )

    def _rows_added(self, connection_index, schema: str, parent, first, last):
        if parent != connection_index:
            return

        for row in range(first, last + 1):
            new_child_index = self.browser_model.index(row, 0, parent)
            new_child_item = self.browser_model.dataItem(new_child_index)
            new_schema = new_child_item.path().split("/")[-1]
            if schema == new_schema:
                self.browser_view.selectionModel().select(
                    self.proxy_model.mapFromSource(new_child_index),
                    QItemSelectionModel.ClearAndSelect,
                )

    def selected_connection_name(self) -> Optional[str]:
        """
        Returns the selected connection name
        """
        selection = self.browser_view.selectionModel().selection()
        if not selection.indexes():
            return None

        selected_item = self.browser_model.dataItem(
            self.proxy_model.mapToSource(selection.indexes()[0])
        )
        path_parts = selected_item.path().split("/")
        return path_parts[1]

    def selected_schema_name(self) -> Optional[str]:
        """
        Returns the selected schema name
        """
        selection = self.browser_view.selectionModel().selection()
        if not selection.indexes():
            return None

        selected_item = self.browser_model.dataItem(
            self.proxy_model.mapToSource(selection.indexes()[0])
        )
        path_parts = selected_item.path().split("/")
        return path_parts[2]
