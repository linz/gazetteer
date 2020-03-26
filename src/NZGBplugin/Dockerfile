FROM kartoza/qgis-desktop:2.14

# Disabled no-more-available qgis apt repositories
RUN sed -i 's/\(.*qgis.org\)/#\1/' /etc/apt/sources.list

# Install plugin requirements.
# Note: upgrade of libssl-dev is needed to build geoalchemy
RUN apt-get update && apt-get install -y \
  libssl-dev \
  python-pip

# NOTE: sqlalchemy 0.9+ breaks compatibility
#       of geoalchemy, see
#       https://github.com/geoalchemy/geoalchemy/pull/35
#       They _need_ to be installed by the same pip call
#       otherwise `geoalchemy` install will request
#       to install sqlalchemy>=0.6.1 (not limiting to newer)
RUN pip install geoalchemy sqlalchemy'<0.9'


## Set NZGBplugin as enabled in config
#RUN mkdir -p /root/.config/QGIS
#RUN echo '[PythonPlugins]' >  /root/.config/QGIS/QGIS2.conf
#RUN echo 'NZGBplugin=true' >> /root/.config/QGIS/QGIS2.conf
#
## Do not show startup tips in QGIS..
#RUN echo '[Qgis]' >> /root/.config/QGIS/QGIS2.conf
#RUN echo 'showTips214=false' >> /root/.config/QGIS/QGIS2.conf

#ADD .  /root/.qgis2/python/plugins/NZGBplugin

