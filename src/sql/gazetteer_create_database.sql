CREATE DATABASE gazetteer;
--
-- Note: after creating database need to install PostGis
--
-- psql -d gazetteer -f postgis.sql
-- psql -d gazetteer -f spatial_ref_sys.sql

ALTER DATABASE gazetteer OWNER TO gaz_owner;
GRANT ALL ON DATABASE gazetteer to gazetteer_dba;
