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


set search_path=gazetteer,public;

DROP SCHEMA IF EXISTS gazetteer_export CASCADE;
CREATE SCHEMA gazetteer_export;
GRANT ALL PRIVILEGES ON SCHEMA gazetteer_export TO gazetteer_dba;
GRANT USAGE ON SCHEMA gazetteer_export TO gazetteer_export;
