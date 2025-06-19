FROM debian:bookworm

# Pass via env, like: docker build --build-arg PGSQL_VERSION=12 ...
ARG  PGSQL_VERSION=12

# Install postgresql.org APT source
RUN apt-get update && apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  && apt-get clean
RUN install -d /usr/share/postgresql-common/pgdg
RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL and packages needed to build
# PostGIS from source
RUN apt-get update && apt-get install -y \
  postgresql-${PGSQL_VERSION} \
  postgresql-server-dev-${PGSQL_VERSION} \
  postgresql-${PGSQL_VERSION}-postgis-3 \
  build-essential autoconf libtool libcunit1-dev \
  xsltproc docbook-xsl docbook-mathml \
  libproj-dev libjson-c-dev libxml2-dev \
  flex bison unzip imagemagick \
  libprotobuf-c-dev protobuf-c-compiler libgdal-dev python3 \
  libtap-parser-sourcehandler-pgtap-perl \
  && apt-get clean

# Install gazeteer schema
ADD *.sql build_gazetteer_export.py _export_helpers.py install.sh /sql/
RUN touch /sql/gazetteer_export.sql && \
    chown postgres /sql/gazetteer_export.sql

RUN pg_ctlcluster ${PGSQL_VERSION} main start && \
    export PGDIR=$('ls' -d /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-* | head -1) && \
    echo "PGDIR=${PGDIR}" && \
    su -m postgres -c 'echo "PGDIR(postgres)=${PGDIR}"' && \
    su postgres -c 'createdb gazetteer' && \
    su postgres -c 'psql -f /sql/gazetteer_roles.sql gazetteer' && \
    ( su postgres -c 'createlang plpgsql gazetteer' || true; ) && \
    su -m postgres -c 'psql -f ${PGDIR}/postgis.sql gazetteer' && \
    su -m postgres -c 'psql -f ${PGDIR}/spatial_ref_sys.sql gazetteer' && \
    su postgres -c 'cd /sql; ./install.sh drop'

ADD install_web.sh /sql/
RUN pg_ctlcluster ${PGSQL_VERSION} main start && \
    su postgres -c 'cd /sql; ./install_web.sh drop'

RUN echo "host all all 172.0.0.0/8 md5" >> /etc/postgresql/${PGSQL_VERSION}/main/pg_hba.conf
RUN echo "host all all 192.168.0.0/16 md5" >> /etc/postgresql/${PGSQL_VERSION}/main/pg_hba.conf

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

ENV PGSQL_VERSION=${PGSQL_VERSION}

#EXPOSE 5432
#COPY docker_entrypoint.sh /
ENTRYPOINT su -m - postgres -c "/usr/lib/postgresql/${PGSQL_VERSION}/bin/postgres \
  -D /var/lib/postgresql/${PGSQL_VERSION}/ \
  -c config_file=/etc/postgresql/${PGSQL_VERSION}/main/postgresql.conf \
  -c listen_addresses='*' \
  "

