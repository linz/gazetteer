New Zealand Geographic Board gazetteer application
==================================================

The New Zealand Geographic Board (NZGB) QGIS plugin is an application that
allows the Geographic board to manage official and unofficial names.  It
keeps a record of decisions about names, events that have affected their
status, and identifies the physical locations associated with those names.

The gazetteer data is held in a PostgreSQL database using PostGIS for
spatial feature definition.

The user application is a QGIS plugin (application) providing tools for
creating, searching, amending names.  The user interface is built using
QGIS for the spatial representation and the Qt4 webkit tools for displaying
and amending attribute data.

The QGIS database and application are also used to publish data onto the
web.  The web application is not included in this repository.  However the
database schema to which it publishes is.

More details of the technology implementation are available in the
developer notes at /src/NZGBplugin/help/devnotes.html.  User help is
in the file /src/NZGBplugin/help/index.html.
