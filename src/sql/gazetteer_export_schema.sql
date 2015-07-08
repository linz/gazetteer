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


set search_path=gazetteer,public;

DROP SCHEMA IF EXISTS gazetteer_export CASCADE;
CREATE SCHEMA gazetteer_export;
GRANT ALL PRIVILEGES ON SCHEMA gazetteer_export TO gazetteer_dba;
GRANT USAGE ON SCHEMA gazetteer_export TO gazetteer_export;
