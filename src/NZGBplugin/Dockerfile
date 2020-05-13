FROM qgis/qgis:final-3_10_5

# Disabled no-more-available qgis apt repositories
#RUN sed -i 's/\(.*qgis.org\)/#\1/' /etc/apt/sources.list

# Install plugin requirements.
# Note: upgrade of libssl-dev is needed to build geoalchemy
RUN apt-get update && apt-get install -y \
  libssl-dev \
  python3-pip

# NOTE: sqlalchemy 0.9+ breaks compatibility
#       of geoalchemy, see
#       https://github.com/geoalchemy/geoalchemy/pull/35
#       They _need_ to be installed by the same pip call
#       otherwise `geoalchemy` install will request
#       to install sqlalchemy>=0.6.1 (not limiting to newer)
RUN pip3 install geoalchemy2 sqlalchemy'<0.9'

# qgis:final-3_10_4_disco requires jinja2 to run MetaSerach
# See https://github.com/qgis/QGIS/issues/35480
RUN pip3 install jinja2

# qgis:final-3_10_4_disco requires pygments to run MetaSerach
# See https://github.com/qgis/QGIS/issues/35480
RUN pip3 install pygments
