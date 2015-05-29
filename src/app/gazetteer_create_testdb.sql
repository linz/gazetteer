CREATE DATABASE gaz_test;
--
-- Note: after creating database need to install PostGis
--
-- psql -d gazetteer -f postgis.sql
-- psql -d gazetteer -f spatial_ref_sys.sql

ALTER DATABASE gaz_test OWNER TO gaz_owner;
GRANT ALL ON DATABASE gaz_test to gazetteer_dba;

CREATE DATABASE gaz_dev;
--
-- Note: after creating database need to install PostGis
--
-- psql -d gazetteer -f postgis.sql
-- psql -d gazetteer -f spatial_ref_sys.sql

ALTER DATABASE gaz_dev OWNER TO gaz_owner;
GRANT ALL ON DATABASE gaz_dev to gazetteer_dba;
