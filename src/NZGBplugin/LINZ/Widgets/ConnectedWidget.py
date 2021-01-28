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

from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *

from .ValidatorList import ValidatorList
from .WidgetConnector import WidgetConnector


class ConnectedWidget(QWidget):
    """
    Widget to use as a container for a set of widgets for editing an
    object using an Adaptor interface and WidgetConnector.

    The widget can contain a set of controls for editing the object
    attributes using a naming convention of prefix + attribute_name.
    It may also contain a "Save" and "Cancel" button, which will be
    linked to corresponding events on the object.

    The widget should be initiallized with a call to setAdaptor, which
    defines the Adaptor to use, and the string prefix identifying controls
    linked to adapted attributes.

    Validators for fields can be added as well as form validators,
    using add Validator.

    The widget emits events loaded, saved, and cancelled, to mark changes
    in the object state.
    """

    loaded = pyqtSignal(object, name="loaded")
    saved = pyqtSignal(object, name="saved")
    cancelled = pyqtSignal(object, name="cancelled")

    def __init__(self, parent=None):
        QWidget.__init__(self, parent)
        self._connector = None
        self._prefix = ""
        self._typename = None
        self._object = None
        self._isnew = False
        self._saveButton = None
        self._cancelButton = None
        self._validators = ValidatorList(self)

    def setAdaptor(self, adaptor, prefix=None, typename=None):
        """
        Defines the adaptor used by the connector to access object
        attributes, the prefix used to identify controls to which the
        adaptor will connect, and the typename used

        Associates child controls named prefix+attribute with adaptor
        attributes.

        Also connects the save and cancel buttons (prefix+'save_button', prefix+'cancel_button')
        """
        if self._connector:
            raise RuntimeError("Cannot reset adaptor in " + self.objectName())

        if not typename:
            typename = adaptor.type()
        if not prefix:
            prefix = adaptor.type() + "_"

        self._prefix = prefix
        self._typename = typename
        self._connector = WidgetConnector(self, adaptor, prefix)
        self._connector.dataChanged.connect(self._enableButtons)
        self._saveButton = self.findChild(QPushButton, self._prefix + "save_button")
        self._cancelButton = self.findChild(QPushButton, self._prefix + "cancel_button")
        if self._saveButton:
            self._saveButton.clicked.connect(self.save)
        if self._cancelButton:
            self._cancelButton.clicked.connect(self.cancel)
        self.load(None)

    def addValidator(self, widget, validator, message=None):
        """
        Adds a validator to the widget. Applies when saving a widget.

        widget may be a widget on the form or the name of an attribute

        validator - may be a string defining a regular expression, or a
        QValidator, or a function returning true or false

        message is an optional message that will be displayed if
        validation fails
        """
        if isinstance(widget, str):
            widget = self.findChild(QWidget, self._prefix + widget)
        if not widget:
            widget = self
        self._validators.addValidator(widget, validator, message)

    def load(self, object_, isNew=False, overwrite=False):
        """
        Loads an object into the widget.

        object_ is the object to load

        isNew is boolean defining whether the object is a new or previously existing object

        overwrite is a boolean defining whether the current object should be overwritten
        without asking if it is "dirty"
        """
        if not self._connector:
            raise RuntimeError(
                "Cannot use load before setAdaptor in " + self.objectName()
            )
        if self._object and not overwrite and not self.querySave():
            return False
        self._object = object_
        self._isnew = isNew and object_ != None
        self._load()
        self.loaded.emit(self._object)
        return True

    def loadedObject(self):
        """
        Return the object that has been loaded into the ConnectedWidget
        """
        return self._object

    def isNew(self):
        """
        returns the isNew status from the last call to load(..)
        """

        return self._isnew

    def _load(self):
        self._connector.load(self._object)
        self._enableButtons()

    def _enableButtons(self):
        enabled = False
        if self._object:
            enabled = self._connector.isDirty()
        if self._saveButton:
            self._saveButton.setEnabled(enabled)
        if self._cancelButton:
            self._cancelButton.setEnabled(enabled or self._isnew)

    def querySave(self):
        """
        Offers to save the object if it is "dirty".

        Returns True if the object is successfully saved, or the user
        chose not to save it, or False if user cancelled the save operation.
        """
        if self._object == None or not self._connector.isDirty():
            return True
        result = QMessageBox.question(
            self,
            "Save " + self._typename + "?",
            "Do you want to save the " + self._typename + "?",
            QMessageBox.Yes | QMessageBox.No | QMessageBox.Cancel,
            QMessageBox.Yes,
        )
        if result == QMessageBox.Cancel:
            return False
        if result == QMessageBox.No:
            self._load()
            return True
        return self.save()

    def validate(self):
        """
        Runs the widget validators, displays a dialogue box alterting to
        possible problems and moving the focus onto the first widget with
        a problem

        return True if there are no problems, False if there are

        """
        isok, messages, widget = self._validators.validate()
        if not isok:
            QMessageBox.warning(
                self, "Errors in " + self._typename, "\n".join(messages)
            )
            if widget:
                widget.setFocus(Qt.OtherFocusReason)
        return isok

    def save(self):
        """
        Attempts to save the widget data into current object
        """
        if not self._object:
            return True
        if not self.validate():
            return False
        try:
            self._connector.save(self._isnew)
            self.saved.emit(self._object)
            return True
        except Exception as e:
            QMessageBox.warning(self, "Error saving " + self._typename, e.message)
            return False

    def cancel(self):
        """
        Reloads the current object, overwriting any user entry
        """
        self._load()
        self.cancelled.emit(self._object)
