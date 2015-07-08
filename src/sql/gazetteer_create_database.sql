-- ###############################################################################
-- 
--  Copyright 2015 Crown copyright (c)
--  Land Information New Zealand and the New Zealand Government.
--  All rights reserved
-- 
--  This program is released under the terms of the new BSD license. See the 
--  LICENSE file for more information.
-- 
-- ###############################################################################

CREATE DATABASE gazetteer;
--
-- Note: after creating database need to install PostGis
--
-- psql -d gazetteer -f postgis.sql
-- psql -d gazetteer -f spatial_ref_sys.sql

ALTER DATABASE gazetteer OWNER TO gaz_owner;
GRANT ALL ON DATABASE gazetteer to gazetteer_dba;
