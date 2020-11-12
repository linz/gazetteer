FROM debian:jessie

# Pass via env, like: docker build --build-arg PGSQL_VERSION=12 ...
ARG  PGSQL_VERSION=8.4
ARG  PGIS_VERSION=1.5.8
ARG  GEOS_VERSION=3.8.1

# Install postgresql.org APT source
RUN apt-get update && apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  && apt-get clean
RUN curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL and packages needed to build
# PostGIS from source
RUN apt-get update && apt-get install -y \
  postgresql-${PGSQL_VERSION} \
  postgresql-server-dev-${PGSQL_VERSION} \
  build-essential autoconf libtool libcunit1-dev \
  xsltproc docbook-xsl docbook-mathml \
  libproj-dev libjson0-dev libxml2-dev \
  flex bison unzip imagemagick \
  && apt-get clean

# Install GEOS from source
RUN curl -s -L \
  https://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 | \
  tar xj && cd geos-${GEOS_VERSION} && \
  ./configure && make && make install && \
  cd .. && rm geos-${GEOS_VERSION} -rf

# Install PostGIS ${PGIS_VERSION} from source
RUN curl -s -L \
  https://ftp.osuosl.org/pub/osgeo/download/postgis/source/postgis-${PGIS_VERSION}.tar.gz | \
  tar xz && cd postgis-${PGIS_VERSION} && \
  ./configure && make && make install && \
  cd .. && rm postgis-${PGIS_VERSION} -rf

# Install gazeteer schema
ADD *.sql build_gazetteer_export.py install.sh /sql/
RUN touch /sql/gazetteer_export.sql && \
    chown postgres /sql/gazetteer_export.sql

RUN pg_ctlcluster ${PGSQL_VERSION} main start && \
    export PGDIR=$('ls' -d /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-* | head -1) && \
    su postgres -c 'createdb gazetteer' && \
    su postgres -c 'psql -f /sql/gazetteer_roles.sql gazetteer' && \
    su postgres -c 'createlang plpgsql gazetteer' && \
    su -m postgres -c 'psql -f ${PGDIR}/postgis.sql gazetteer' && \
    su -m postgres -c 'psql -f ${PGDIR}/spatial_ref_sys.sql gazetteer' && \
    su postgres -c 'cd /sql; ./install.sh drop'

ADD install_web.sh /sql/
RUN pg_ctlcluster ${PGSQL_VERSION} main start && \
    su postgres -c 'cd /sql; ./install_web.sh drop'

RUN echo "host all all 172.0.0.0/8 md5" >> /etc/postgresql/${PGSQL_VERSION}/main/pg_hba.conf
RUN echo "host all all 192.168.0.0/16 md5" >> /etc/postgresql/${PGSQL_VERSION}/main/pg_hba.conf

#EXPOSE 5432
#COPY docker_entrypoint.sh /
ENTRYPOINT su - postgres -c "/usr/lib/postgresql/${PGSQL_VERSION}/bin/postgres \
  -D /var/lib/postgresql/${PGSQL_VERSION}/ \
  -c config_file=/etc/postgresql/${PGSQL_VERSION}/main/postgresql.conf \
  -c listen_addresses='*' \
  "

RUN pg_ctlcluster ${PGSQL_VERSION} main start && \
    echo "create user gazowner IN ROLE gaz_owner password 'gazowner'" | \
    su postgres -c psql && \
    echo "create user gazexport IN ROLE gazetteer_export password 'gazexport'" | \
    su postgres -c psql && \
    echo "create user gazuser IN ROLE gazetteer_user password 'gazuser'" | \
    su postgres -c psql && \
    echo "create user gazadmin IN ROLE gazetteer_admin password 'gazadmin'" | \
    su postgres -c psql && \
    echo "create user gazdba IN ROLE gazetteer_admin, gazetteer_dba password 'gazdba'" | \
    su postgres -c psql

ADD test/pgtap_load /pgtap_load

RUN pg_ctlcluster ${PGSQL_VERSION} main start && \
    cd /tmp && \
    su postgres -c 'sh /pgtap_load gazetteer'

RUN apt-get update && apt-get install -y \
    libtap-parser-sourcehandler-pgtap-perl
