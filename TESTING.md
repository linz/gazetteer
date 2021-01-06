# Testing tools

This repository comes with configuration to build and run
2 docker containers:

  - A PostgreSQL database container, with a prepared gazetteer
    database

  - A QGIS container, with a version of QGIS known to work
    with the plugin, which is preloaded

The easiest way to run both containers, already linked,
and immediately get to use the QGIS plugin is provided
as a Makefile target:

      make docker-qgis-start

Other Makefile targets do exist and are documented when
`make` is invoked with no arguments:

      make

The database container runs with pre-created PostgreSQL
cluster users that can be used to load data or otherwise
inspect the database. You can open a psql session into
the database with:

      make docker-db-connect

NOTE: any data loaded into the database will disappear
with the container, which is volatile.
