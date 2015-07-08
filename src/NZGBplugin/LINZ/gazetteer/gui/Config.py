
# Configuration settings for NZGB plugin

from PyQt4.QtCore import *

organisationName='Land Information New Zealand'
applicationName='Gazetteer Administration'
_settings=None

def settings():
    global _settings
    if not _settings:
        _settings = QSettings( organisationName, applicationName )
    return _settings

def set( item, value ):
    settings().setValue(item,value)

def get( item, default='' ):
    value=settings().value(item,default)
    if 'toString' in dir(value):
        value=value.toString()
    value = str(value)
    return value

def remove( item ):
    settings().remove( item )
