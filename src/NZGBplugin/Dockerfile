FROM qgis/qgis:release-3_4

ADD .  /root/.local/share/QGIS/QGIS3/profiles/default/python/plugins/NZGBplugin

RUN qgis_setup.sh NZGBplugin

RUN echo '#!/bin/sh' > /usr/local/bin/qgis_on
RUN echo 'DISPLAY=$1 qgis' >> /usr/local/bin/qgis_on
RUN chmod +x /usr/local/bin/qgis_on

#RUN ln -fs /tests_directory /root/.local/share/QGIS/QGIS3/profiles/default/python/plugins
