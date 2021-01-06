FROM debian:jessie

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
  postgresql-8.4 \
  postgresql-server-dev-8.4 \
  build-essential autoconf libtool libcunit1-dev \
  xsltproc docbook-xsl docbook-mathml \
  libproj-dev libjson0-dev libxml2-dev \
  flex bison unzip imagemagick \
  libgeos-dev && apt-get clean

# Install PostGIS 1.5.8 from source
RUN curl -s -L \
  https://ftp.osuosl.org/pub/osgeo/download/postgis/source/postgis-1.5.8.tar.gz | \
  tar xz && cd postgis-1.5.8 && \
  ./configure && make && make install && \
  cd .. && rm postgis-1.5.8 -rf

# Install gazeteer schema
ADD *.sql build_gazetteer_export.py install.sh /sql/
RUN touch /sql/gazetteer_export.sql && \
    chown postgres /sql/gazetteer_export.sql

RUN pg_ctlcluster 8.4 main start && \
    su postgres -c 'createdb gazetteer' && \
    su postgres -c 'psql -f /sql/gazetteer_roles.sql gazetteer' && \
    su postgres -c 'createlang plpgsql gazetteer' && \
    su postgres -c 'psql -f /usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql gazetteer' && \
    su postgres -c 'psql -f /usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql gazetteer' && \
    su postgres -c 'cd /sql; ./install.sh drop'

ADD install_web.sh /sql/
RUN pg_ctlcluster 8.4 main start && \
    su postgres -c 'cd /sql; ./install_web.sh drop'

RUN echo "host all all 172.0.0.0/8 md5" >> /etc/postgresql/8.4/main/pg_hba.conf
RUN echo "host all all 192.168.0.0/16 md5" >> /etc/postgresql/8.4/main/pg_hba.conf

#EXPOSE 5432
#COPY docker_entrypoint.sh /
ENTRYPOINT su - postgres -c "/usr/lib/postgresql/8.4/bin/postgres \
  -D /var/lib/postgresql/8.4/ \
  -c config_file=/etc/postgresql/8.4/main/postgresql.conf \
  -c listen_addresses='*' \
  "

RUN pg_ctlcluster 8.4 main start && \
    echo "create user gazadmin IN ROLE gazetteer_admin password 'gazadmin'" | \
    su postgres -c psql
