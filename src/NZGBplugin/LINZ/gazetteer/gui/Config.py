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


# Configuration settings for NZGB plugin

from builtins import str
from PyQt5.QtCore import *

organisationName = "Land Information New Zealand"
applicationName = "Gazetteer Administration"
_settings = None


def settings():
    global _settings
    if not _settings:
        _settings = QSettings(organisationName, applicationName)
    return _settings


def set(item, value):
    settings().setValue(item, value)


def get(item, default=""):
    value = settings().value(item, default)
    if "toString" in dir(value):
        value = value.toString()
    value = str(value)
    return value


def remove(item):
    settings().remove(item)
