-- ################################################################################
--
--  New Zealand Geographic Board gazetteer application,
--  Crown copyright (c) 2020, Land Information New Zealand on behalf of
--  the New Zealand Government.
--
--  This file is released under the MIT licence. See the LICENCE file found
--  in the top-level directory of this distribution for more information.
--
-- ################################################################################

CREATE DATABASE gazetteer;
--
-- Note: after creating database need to install PostGis
--
-- psql -d gazetteer -f postgis.sql
-- psql -d gazetteer -f spatial_ref_sys.sql

ALTER DATABASE gazetteer OWNER TO gaz_owner;
GRANT ALL ON DATABASE gazetteer to gazetteer_dba;
