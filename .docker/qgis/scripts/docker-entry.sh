#!/bin/sh

PLUGINDIR=~/.local/share/QGIS/QGIS3/profiles/default/python/plugins/NZGBplugin

# Enable the NZGBplugin in qgis
/scripts/enable_nzgbplugin || exit 1

# Just something to keep the container alive
tail -F /dev/null
