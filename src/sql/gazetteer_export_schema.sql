﻿
set search_path=gazetteer,public;

DROP SCHEMA IF EXISTS gazetteer_export CASCADE;
CREATE SCHEMA gazetteer_export;
GRANT ALL PRIVILEGES ON SCHEMA gazetteer_export TO gazetteer_dba;
GRANT USAGE ON SCHEMA gazetteer_export TO gazetteer_export;
