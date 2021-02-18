# Pass via env, like: docker build --build-arg UPSTREAM_TAG=release-3_10 ...
ARG  UPSTREAM_TAG=final-3_12_3
FROM qgis/qgis:${UPSTREAM_TAG}

# Disabled no-more-available qgis apt repositories
#RUN sed -i 's/\(.*qgis.org\)/#\1/' /etc/apt/sources.list

# Install plugin requirements.
# Note: upgrade of libssl-dev is needed to build geoalchemy
RUN apt-get update && apt-get install -y \
  libssl-dev \
  python3-pip

RUN pip3 install geoalchemy2 sqlalchemy'==1.3.17'
