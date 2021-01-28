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

-- Tables to support the gazetteer application (ie not data tables)

SET search_path=gazetteer, public;

-- DROP TABLE IF EXISTS app_usage;

CREATE TABLE app_usage
(
    usage_id SERIAL NOT NULL PRIMARY KEY,
    userid NAME NOT NULL,
    name_id INTEGER NOT NULL,
    last_view TIMESTAMP NOT NULL,
    last_edit TIMESTAMP
);

CREATE INDEX app_usage_user_view ON app_usage (userid, last_view );
CREATE INDEX app_usage_user_edit ON app_usage (userid, last_edit );
CREATE INDEX app_usage_view ON app_usage (last_view );
CREATE INDEX app_usage_edit ON app_usage (last_edit );

CREATE TABLE app_favourites
(
    favourite_id SERIAL NOT NULL PRIMARY KEY,
    userid NAME NOT NULL,
    name_id INTEGER NOT NULL
);

CREATE INDEX app_favourites_user_name ON app_usage (userid, name_id );

GRANT SELECT, INSERT, UPDATE, DELETE ON  app_usage TO gazetteer_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON  app_favourites TO gazetteer_admin;
