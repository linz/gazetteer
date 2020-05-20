FROM qgis/qgis:final-3_10_5

# Disabled no-more-available qgis apt repositories
#RUN sed -i 's/\(.*qgis.org\)/#\1/' /etc/apt/sources.list

# Install plugin requirements.
# Note: upgrade of libssl-dev is needed to build geoalchemy
RUN apt-get update && apt-get install -y \
  libssl-dev \
  python3-pip

RUN pip3 install geoalchemy2 sqlalchemy'==1.3.17'
