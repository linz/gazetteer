-- DROP SCHEMA IF EXISTS gazetteer_import CASCADE;

SET client_min_messages=WARNING;

CREATE SCHEMA gazetteer_import AUTHORIZATION gazetteer_dba;

GRANT CREATE, USAGE ON SCHEMA gazetteer_import TO gazetteer_admin;
GRANT USAGE ON SCHEMA gazetteer_import TO gazetteer_user;

SET SEARCH_PATH TO gazetteer_import, gazetteer, public;

-- DROP TABLE IF EXISTS error;

CREATE TABLE error
(
    error_id SERIAL PRIMARY KEY,
    id INT NOT NULL,
    class CHAR(4) NOT NULL,
    subclass CHAR(4),
    official INT DEFAULT 0,
    error TEXT
);
CREATE INDEX error_fid ON error(id);

-- DROP TABLE IF EXISTS error_class;

CREATE TABLE error_class
(
    class CHAR(4) NOT NULL,
    subclass CHAR(4),
    description VARCHAR(255),
    idtype CHAR(4) DEFAULT 'DATA',
    info CHAR(1) DEFAULT 'N',
    primary key( class, subclass )
);

DROP VIEW IF EXISTS official_name_src;
drop table if exists data_source;

create table data_source (src char(4), is_official bool, priority int, description varchar(100));
GRANT SELECT, INSERT, UPDATE, DELETE ON data_source TO gazetteer_admin;


CREATE VIEW official_name_src AS SELECT * FROM data_source WHERE is_official;
