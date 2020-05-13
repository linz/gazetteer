#!/bin/sh

PLUGINDIR=~/.local/share/QGIS/QGIS3/profiles/default/python/plugins/NZGBplugin

# Enable the NZGBplugin in qgis
/scripts/enable_nzgbplugin || exit 1

# Workaround for QGIS issue
#  https://github.com/qgis/QGIS/issues/36187
perl -pi -e \
  's@/dev/tty@/tmp/tty@;s@/tmp/tty\)@/tmp/tty\); echo "\$OUTPUT";@' \
  `which qgis_testrunner.sh` || exit 1

# Just something to keep the container alive
tail -F /dev/null
