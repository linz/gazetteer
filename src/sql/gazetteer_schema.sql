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

-- DROP SCHEMA IF EXISTS gazetteer CASCADE;

SET client_min_messages=WARNING;
SET client_min_messages=WARNING;

CREATE SCHEMA gazetteer AUTHORIZATION gazetteer_dba;

GRANT USAGE ON SCHEMA gazetteer TO gazetteer_admin;
GRANT USAGE ON SCHEMA gazetteer TO gazetteer_user;

SET SEARCH_PATH TO gazetteer, public;

-- Reference tables

-- System codes, used for enumerations etc in the application and tables
-- Some code groups can have a category code defined, which allows splitting
-- the code into categories, eg feature types into feature type classes.
--
-- The code_group CODE defines the code groups in the table
-- The code_group CATE defines the codes groups which have categories, and the code_group
-- of the category.
--

CREATE TABLE system_code
(
    code_group CHAR(4) NOT NULL,
    code CHAR(4) NOT NULL,
    category CHAR(4),
    value VARCHAR(255) NOT NULL,
    description TEXT,
    updated_by NAME,
    update_date TIMESTAMP,
    PRIMARY KEY (code_group, code)
);

-- The feature table.  Defines geographical features to which 
-- names can be associated.

CREATE TABLE feature
(
    feat_id serial NOT NULL PRIMARY KEY,
    feat_type CHAR(4) NOT NULL, -- system code FTYP
    status CHAR(4) NOT NULL,  -- system code FSTS
    description TEXT,
    updated_by NAME,
    update_date TIMESTAMP
);

SELECT AddGeometryColumn( 'gazetteer', 'feature', 'ref_point', 4167, 'POINT', 2 );
CREATE INDEX idx_feature_ref_point ON feature USING Gist( ref_point );

-- Detailed feature geometries .. multiple types of geometry for each feature

CREATE TABLE feature_geometry
(
    geom_id serial NOT NULL PRIMARY KEY,
    feat_id INT NOT NULL REFERENCES feature( feat_id ) ON DELETE CASCADE,
    geom_type CHAR(1) NOT NULL CHECK (geom_type IN ('X','L','P')),
    shape GEOMETRY NOT NULL,
    updated_by NAME,
    update_date TIMESTAMP
);

CREATE INDEX idx_feature_geometry_feat_id ON feature_geometry( feat_id );
CREATE INDEX idx_feature_geometry_shape ON feature_geometry USING Gist(shape);

-- The name table - defines names that may apply to a feature

CREATE TABLE name
(
    name_id serial NOT NULL PRIMARY KEY,
    feat_id INT NOT NULL REFERENCES feature( feat_id ),
    name VARCHAR(1024),
    process CHAR(4), -- system code NPRO
    status CHAR(4), -- system code NSTS
    updated_by NAME,
    update_date TIMESTAMP
);

CREATE INDEX idx_name_feat_id ON name( feat_id );

-- The name event table - defines events that can apply to a feature

CREATE TABLE name_event
(
    event_id serial NOT NULL PRIMARY KEY,
    name_id INT NOT NULL REFERENCES name( name_id ),
    event_date DATE,
    event_type CHAR(4) NOT NULL, -- system code EVTT
    authority CHAR(4) NOT NULL,  -- system code AUTH
    event_reference TEXT,
    notes TEXT,
    updated_by NAME,
    update_date TIMESTAMP
);

CREATE INDEX idx_name_event_name_id ON name_event( name_id );

-- Association between features

CREATE TABLE feature_association
(
    assoc_id serial NOT NULL PRIMARY KEY,
    feat_id_from INT NOT NULL REFERENCES feature(feat_id) ON DELETE CASCADE,
    feat_id_to INT NOT NULL REFERENCES feature(feat_id) ON DELETE CASCADE,
    assoc_type CHAR(4) NOT NULL,
    updated_by name,
    update_date timestamp
);

CREATE INDEX idx_feature_association_feat_id ON feature_association( feat_id_from, feat_id_to );
CREATE INDEX idx_feature_association_feat_id2 ON feature_association( feat_id_to, feat_id_from );

-- Association between names

CREATE TABLE name_association
(
    assoc_id serial NOT NULL PRIMARY KEY,
    name_id_from INT NOT NULL REFERENCES name(name_id) ON DELETE CASCADE,
    name_id_to INT NOT NULL REFERENCES name(name_id) ON DELETE CASCADE,
    assoc_type CHAR(4) NOT NULL,
    updated_by NAME,
    update_date TIMESTAMP
);

CREATE INDEX idx_name_association_name_id ON name_association( name_id_from, name_id_to );
CREATE INDEX idx_name_association_name_id2 ON name_association( name_id_to, name_id_from );

-- Generic annotations for features and names (and potentially events)

CREATE TABLE feature_annotation
(
    annot_id serial NOT NULL PRIMARY KEY,
    feat_id INT NOT NULL REFERENCES feature(feat_id) ON DELETE CASCADE,
    annotation_type CHAR(4) NOT NULL, -- System code FANT
    annotation TEXT,
    updated_by NAME,
    update_date TIMESTAMP
);

CREATE INDEX idx_feature_annot_feat ON feature_annotation( feat_id, annotation_type );

CREATE TABLE name_annotation
(
    annot_id serial NOT NULL PRIMARY KEY,
    name_id INT NOT NULL REFERENCES name(name_id) ON DELETE CASCADE,
    annotation_type CHAR(4) NOT NULL, -- System code NANT
    annotation TEXT,
    updated_by NAME,
    update_date TIMESTAMP
);

CREATE INDEX idx_name_annot_name ON name_annotation( name_id, annotation_type );


GRANT SELECT ON  system_code TO gazetteer_user;
GRANT SELECT ON  feature TO gazetteer_user;
GRANT SELECT ON  feature_geometry TO gazetteer_user;
GRANT SELECT ON  name TO gazetteer_user;
GRANT SELECT ON  name_event TO gazetteer_user;
GRANT SELECT ON  feature_association TO gazetteer_user;
GRANT SELECT ON  name_association TO gazetteer_user;
GRANT SELECT ON  feature_annotation TO gazetteer_user;
GRANT SELECT ON  name_annotation TO gazetteer_user;

GRANT SELECT, INSERT, UPDATE, DELETE ON  system_code TO gazetteer_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON  feature TO gazetteer_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON  feature_geometry TO gazetteer_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON  name TO gazetteer_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON  name_event TO gazetteer_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON  feature_association TO gazetteer_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON  name_association TO gazetteer_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON  feature_annotation TO gazetteer_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON  name_annotation TO gazetteer_admin;
