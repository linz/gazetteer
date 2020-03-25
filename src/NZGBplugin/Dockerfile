FROM kartoza/qgis-desktop:2.14

ADD .  /root/.qgis2/python/plugins/NZGBplugin

# Disabled no-more-available qgis apt repositories
RUN sed -i 's/\(.*qgis.org\)/#\1/' /etc/apt/sources.list

# Install plugin requirements.
# Note: upgrade of libssl-dev is needed to build geoalchemy
RUN apt-get update && apt-get install -y \
  libssl-dev \
  python-pip \
  python-sqlalchemy

RUN pip install geoalchemy

#RUN qgis_setup.sh NZGBplugin

#RUN ln -fs /tests_directory /root/.local/share/QGIS/QGIS3/profiles/default/python/plugins

