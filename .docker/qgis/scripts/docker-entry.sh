#!/bin/sh

# Enable the NZGBplugin in qgis
/scripts/enable_nzgbplugin || exit 1

# Configure the NZGBplugin
python3 \
  ~/.qgis3/python/plugins/NZGBplugin/LINZ/gazetteer/gui/DatabaseConfiguration.py \
  host=${PGHOST} \
  database=${PGDATABASE} \
  user=${PGUSER} \
  password=${PGPASSWORD} \
|| exit 1

# Just something to keep the container alive
tail -F /dev/null
