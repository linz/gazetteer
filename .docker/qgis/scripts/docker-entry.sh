#!/bin/sh

PLUGINDIR=~/.local/share/QGIS/QGIS3/profiles/default/python/plugins/NZGBplugin

# Enable the NZGBplugin in qgis
/scripts/enable_nzgbplugin || exit 1

# Configure the NZGBplugin
python3 \
  ${PLUGINDIR}/LINZ/gazetteer/gui/DatabaseConfiguration.py \
  host=${PGHOST} \
  database=${PGDATABASE} \
  user=${PGUSER} \
  password=${PGPASSWORD} \
|| exit 1

# Just something to keep the container alive
tail -F /dev/null
