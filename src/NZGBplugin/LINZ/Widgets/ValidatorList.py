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
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *


class ValidatorList(QObject):
    class Validator(QObject):
        def __init__(self, parent, widget, validator, message):
            QObject.__init__(self, parent)
            self.widget = widget
            self.validate = validator
            self.message = message

    def __init__(self, parent=None):
        QObject.__init__(self, parent)
        self._parent = parent
        self._validators = []

    def parent(self):
        return _self.parent

    def setParent(self, parent):
        self._parent = parent

    def addValidator(self, widget, validator, message):
        validfunc = None
        if not message and widget:
            message = "Error in " + widget.objectName()
        if not message:
            message = "Error in validator " + str(validator)
        if callable(validator):
            validfunc = validator
        else:
            if isinstance(validator, str):
                validator = QRegExp(validator)
            if isinstance(validator, QRegExp):
                validator = QRegExpValidator(QRegExp(validator), self._parent)
            if isinstance(validator, QValidator):
                if isinstance(widget, QLineEdit):
                    widget.setValidator(validator)
                    validfunc = (
                        lambda: validator.validate(widget.text(), 0)[0]
                        == QValidator.Acceptable
                    )
        if callable(validfunc):
            self._validators.append(
                ValidatorList.Validator(self, widget, validfunc, message)
            )
        else:
            raise RuntimeError(
                str(validator) + " is not a validator for " + widget.objectName()
            )

    def validate(self):
        messages = []
        valid = True
        widget = None
        for v in self._validators:
            if not v.validate():
                valid = False
                messages.append(v.message)
                if not widget:
                    widget = v.widget
        return valid, messages, widget
