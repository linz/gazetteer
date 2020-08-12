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

SET search_path=gazetteer, public;

-- feature_ref_point view

DROP VIEW IF EXISTS feature_ref_point;
CREATE VIEW feature_ref_point AS
SELECT
    feature.feat_id,
    gaz_preferredName(feat_id) as name,
    feature.feat_type,
    feature.ref_point
from
    gazetteer.feature;

CREATE OR REPLACE RULE feature_ref_point_ins AS ON INSERT TO feature_ref_point
DO INSTEAD
    (
    INSERT INTO feature (feat_type, status, description, ref_point )
    VALUES (NEW.feat_type, 'CURR', '', NEW.ref_point );
    INSERT INTO name (feat_id, name, status )
    VALUES (lastval(), NEW.name, 'UNEW' )
    RETURNING
        feat_id,
        gaz_preferredname(feat_id),
       	(SELECT feat_type
		FROM gazetteer.feature
		ORDER BY feat_id DESC
		LIMIT 1),
  		(SELECT ref_point
		FROM gazetteer.feature
		ORDER BY feat_id DESC
		LIMIT 1)
	);

CREATE OR REPLACE RULE feature_ref_point_upd AS ON UPDATE TO feature_ref_point
DO INSTEAD
    UPDATE gazetteer.feature
    SET
        ref_point = NEW.ref_point
    WHERE feat_id = NEW.feat_id;

-- -------------------------------------
-- Views of geometry table

DROP VIEW IF EXISTS feature_point;
CREATE VIEW feature_point AS
SELECT
    geom_id,
    feat_id,
    gaz_preferredName(feat_id) as name,
    shape
FROM
    gazetteer.feature_geometry
WHERE
    geom_type='X';

DROP VIEW IF EXISTS feature_line;
CREATE VIEW feature_line AS
SELECT
    geom_id,
    feat_id,
    gaz_preferredName(feat_id) as name,
    shape
FROM
    gazetteer.feature_geometry
WHERE
    geom_type='L';

DROP VIEW IF EXISTS feature_polygon;
CREATE VIEW feature_polygon AS
SELECT
    geom_id,
    feat_id,
    gaz_preferredName(feat_id) as name,
    shape
FROM
    gazetteer.feature_geometry
WHERE
    geom_type='P';

CREATE OR REPLACE RULE feature_point_ins AS ON INSERT TO feature_point
DO INSTEAD
    INSERT INTO gazetteer.feature_geometry(
        feat_id,
        geom_type,
        shape
        )
    VALUES (
        NEW.feat_id,
        CASE
            WHEN GeometryType( NEW.SHAPE) like '%POINT' THEN 'X'
            WHEN GeometryType( NEW.SHAPE) like '%LINESTRING' THEN 'L'
            WHEN GeometryType( NEW.SHAPE) like '%POLYGON' THEN 'P'
        END,
        NEW.shape
        )
    RETURNING
  		(SELECT geom_id
		FROM gazetteer.feature_geometry
		ORDER BY geom_id DESC
		LIMIT 1),
        feat_id,
        gaz_preferredname(feat_id),
        shape;

CREATE OR REPLACE RULE feature_point_upd AS ON UPDATE TO feature_point
DO INSTEAD
    UPDATE gazetteer.feature_geometry
    SET
        feat_id = NEW.feat_id,
        geom_type =
            CASE
                WHEN GeometryType( NEW.SHAPE) like '%POINT' THEN 'X'
                WHEN GeometryType( NEW.SHAPE) like '%LINESTRING' THEN 'L'
                WHEN GeometryType( NEW.SHAPE) like '%POLYGON' THEN 'P'
            END,
        shape = NEW.shape
    WHERE geom_id = NEW.geom_id;

CREATE OR REPLACE RULE feature_point_del AS ON DELETE TO feature_point
DO INSTEAD
    DELETE FROM gazetteer.feature_geometry
    WHERE geom_id = OLD.geom_id;


CREATE OR REPLACE RULE feature_line_ins AS ON INSERT TO feature_line
DO INSTEAD
    INSERT INTO gazetteer.feature_geometry(
        feat_id,
        geom_type,
        shape
        )
    VALUES (
        NEW.feat_id,
        CASE
            WHEN GeometryType( NEW.SHAPE) like '%POINT' THEN 'X'
            WHEN GeometryType( NEW.SHAPE) like '%LINESTRING' THEN 'L'
            WHEN GeometryType( NEW.SHAPE) like '%POLYGON' THEN 'P'
        END,
        NEW.shape
        )
    RETURNING
  		(SELECT geom_id
		FROM gazetteer.feature_geometry
		ORDER BY geom_id DESC
		LIMIT 1),
        feat_id,
        gaz_preferredname(feat_id),
        shape;

CREATE OR REPLACE RULE feature_line_upd AS ON UPDATE TO feature_line
DO INSTEAD
    UPDATE gazetteer.feature_geometry
    SET
        feat_id = NEW.feat_id,
        geom_type =
            CASE
                WHEN GeometryType( NEW.SHAPE) like '%POINT' THEN 'X'
                WHEN GeometryType( NEW.SHAPE) like '%LINESTRING' THEN 'L'
                WHEN GeometryType( NEW.SHAPE) like '%POLYGON' THEN 'P'
            END,
        shape = NEW.shape
    WHERE geom_id = NEW.geom_id;

CREATE OR REPLACE RULE feature_line_del AS ON DELETE TO feature_line
DO INSTEAD
    DELETE FROM gazetteer.feature_geometry
    WHERE geom_id = OLD.geom_id;


CREATE OR REPLACE RULE feature_polygon_ins AS ON INSERT TO feature_polygon
DO INSTEAD
    INSERT INTO gazetteer.feature_geometry(
        feat_id,
        geom_type,
        shape
        )
    VALUES (
        NEW.feat_id,
        CASE
            WHEN GeometryType( NEW.SHAPE) like '%POINT' THEN 'X'
            WHEN GeometryType( NEW.SHAPE) like '%LINESTRING' THEN 'L'
            WHEN GeometryType( NEW.SHAPE) like '%POLYGON' THEN 'P'
        END,
        NEW.shape
        )
    RETURNING
  		(SELECT geom_id
		FROM gazetteer.feature_geometry
		ORDER BY geom_id DESC
		LIMIT 1),
        feat_id,
        gaz_preferredname(feat_id),
        shape;

CREATE OR REPLACE RULE feature_polygon_upd AS ON UPDATE TO feature_polygon
DO INSTEAD
    UPDATE gazetteer.feature_geometry
    SET
        feat_id = NEW.feat_id,
        geom_type =
        CASE
            WHEN GeometryType( NEW.SHAPE) like '%POINT' THEN 'X'
            WHEN GeometryType( NEW.SHAPE) like '%LINESTRING' THEN 'L'
            WHEN GeometryType( NEW.SHAPE) like '%POLYGON' THEN 'P'
        END,
        shape = NEW.shape
    WHERE geom_id = NEW.geom_id;

CREATE OR REPLACE RULE feature_polygon_del AS ON DELETE TO feature_polygon
DO INSTEAD
    DELETE FROM gazetteer.feature_geometry
    WHERE geom_id = OLD.geom_id;

DELETE FROM geometry_columns
    WHERE f_table_schema='gazetteer' AND
        f_table_name IN ('feature_ref_point', 'feature_point', 'feature_line', 'feature_polygon');

INSERT INTO geometry_columns(f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, "type")
VALUES
    ('', 'gazetteer', 'feature_ref_point', 'ref_point', 2, 4167, 'POINT'),
    ('', 'gazetteer', 'feature_point', 'shape', 2, 4167, 'POINT'),
    ('', 'gazetteer', 'feature_line', 'shape', 2, 4167, 'LINESTRING'),
    ('', 'gazetteer', 'feature_polygon', 'shape', 2, 4167, 'POLYGON');
