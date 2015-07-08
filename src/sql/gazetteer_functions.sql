SET search_path=gazetteer, public;
SET search_path=gazetteer, public;

CREATE OR REPLACE FUNCTION gaz_plainText( string TEXT )
RETURNS TEXT
AS
$body$
    SELECT 
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
            $1,
            'ā','a'),
            'ē','e'),
            'ī','i'),
            'ō','o'),
            'ū','u'),
            'Ā','A'),
            'Ē','E'),
            'Ī','I'),
            'Ō','O'),
            'Ū','U'),
            'é','e'),
            'è','e'),
            'ä','a'),
            'ë','e'),
            'ï','i'),
            'ö','o'),
            'ü','u'),
            'Ä','A'),
            'Ë','E'),
            'Ï','I'),
            'Ö','O'),
            'Ü','U'),
            '’','''')
$body$
LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION gaz_textHasMacrons( string TEXT )
RETURNS BOOLEAN
AS
$body$
    SELECT $1 ~ '[āēīōūĀĒĪŌŪ]'
$body$
LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION gaz_plainText2( string TEXT )
RETURNS TEXT
AS
$body$
      SELECT trim(
       regexp_replace(
       regexp_replace(
       lower(gaz_plaintext($1)),
         E'[\\'']','','g'),  -- Characters to delete
         E'[\\)\\(\\,\\.\\&\\;\\/\\-]',' ','g') -- Alternative separators 
         )
$body$
LANGUAGE sql IMMUTABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_plainTextWords( string TEXT )
RETURNS text[]
AS
$body$
      SELECT regexp_split_to_array( gaz_plaintext2( $1 ),E'\\s+')
$body$
LANGUAGE sql IMMUTABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_canDeleteSystemCode( p_code_group CHAR(4), p_code CHAR(4))
RETURNS BOOLEAN
AS
$body$
DECLARE
     v_column VARCHAR;
     v_table VARCHAR;
     v_sql VARCHAR;
     v_field VARCHAR;
     v_count INTEGER;
BEGIN
     -- If this is a code or category definition, and it is in use, then can't delete
     IF p_code_group IN ('CODE','CATE') THEN
         RETURN NOT EXISTS (SELECT * FROM system_code WHERE code_group=p_code);
     END IF;
     -- If this is being used as a category definition for a code then it can't be deleted
     IF EXISTS(
        SELECT 
           *
        FROM
           system_code sc1
           JOIN system_code sc2 ON
               sc2.code_group='CATE' AND sc2.code=sc1.code_group AND sc2.category=p_code_group
        WHERE
           sc1.category=p_code
        ) THEN
        RETURN FALSE;
     END IF; 
     -- If this is being used for a column and there is only one code in this group, then it can't
     -- be deleted
     IF EXISTS (SELECT * FROM system_code WHERE code_group='CUSG' AND code=p_code_group) THEN
        IF NOT EXISTS (SELECT * FROM system_code WHERE code_group=p_code_group AND code<>p_code) THEN
           RETURN FALSE;
        END IF;
     END IF;
     
     -- If this is used in a database column and it is used in that column then it can't be deleted
     FOR v_column IN SELECT unnest(regexp_split_to_array(value,E'\\s+')) FROM system_code WHERE code_group='CUSG' AND code=p_code_group LOOP
       BEGIN
      
         v_table = split_part(v_column,'.',1);
         v_field = split_part(v_column,'.',2);
         v_sql = 'SELECT COUNT(*) FROM ' || quote_ident(v_table) || ' WHERE ' || quote_ident(v_field) || ' = ''' || replace(p_code,'''','''''') || '''';
         RAISE NOTICE 'SQL: %', v_sql;
         EXECUTE v_sql INTO v_count; 
         IF v_count > 0 THEN
            RETURN FALSE;
         END IF;
       EXCEPTION WHEN OTHERS THEN
         -- Silently ignore errors
       END;
     END LOOP;
     
     RETURN TRUE;
     
END
$body$
LANGUAGE plpgsql STABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_nameRelationshipIsTwoWay( p_code VARCHAR(4))
RETURNS BOOLEAN
AS
$body$
    SELECT NOT EXISTS (SELECT * FROM system_code WHERE code_group='NAST' AND code=$1 AND category='ONEW');
$body$
LANGUAGE sql STABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_featureRelationshipIsTwoWay( p_code VARCHAR(4))
RETURNS BOOLEAN
AS
$body$
    SELECT NOT EXISTS (SELECT * FROM system_code WHERE code_group='FAST' AND code=$1 AND category='ONEW');
$body$
LANGUAGE sql STABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_preferredNameId( p_feat_id  INT )
RETURNS INT
AS
$body$
   SELECT 
       n.name_id
   FROM 
       name n
       LEFT OUTER JOIN system_code sc ON sc.code_group='NSTO' AND sc.code=n.status
   WHERE 
       n.feat_id=$1
   ORDER BY
       coalesce(sc.value,'ZZZZ')
   LIMIT 1;
$body$
LANGUAGE sql STABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_preferredName( p_feat_id  INT )
RETURNS varchar
AS
$body$
   SELECT 
       n.name
   FROM 
       name n
       LEFT OUTER JOIN system_code sc ON sc.code_group='NSTO' AND sc.code=n.status
   WHERE 
       n.feat_id=$1
   ORDER BY
       coalesce(sc.value,'ZZZZ')
   LIMIT 1;
$body$
LANGUAGE sql STABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_nameTerritorialAuthority( p_name_id INT )
RETURNS varchar
AS
$body$
    (SELECT MAX(annotation) FROM name_annotation WHERE name_id=$1 AND annotation_type='LDIS')
$body$
LANGUAGE sql STABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_degreesToDms( p_angle FLOAT, p_ndp INT, p_type VARCHAR )
RETURNS varchar
AS
$body$
DECLARE
    
    l_sign INT;
    l_secfmt VARCHAR;
    l_deg INT;
    l_min INT;
    l_sec FLOAT;
    l_offset FLOAT;
    
BEGIN
    l_sign := 1;
    l_sec := p_angle;
    IF p_angle < 0.0 THEN
       l_sign := 2;
       l_sec := -l_sec;
    END IF;
    IF p_type ILIKE 'lat%' THEN
       l_sign := l_sign + 2;
    END IF;
    l_secfmt := '00';
    IF p_ndp > 1 THEN
       l_secfmt := l_secfmt || '.' || repeat('0',p_ndp);
    END IF;

    l_offset := 0.5/(10^p_ndp);
    l_sec := l_sec + l_offset/3600.0;
    l_deg := floor(l_sec)::INT;
    l_sec := (l_sec-l_deg)*60.0;
    l_min := floor(l_sec)::INT;
    l_sec := greatest((l_sec-l_min)*60.0 - l_offset, 0);

    RETURN l_deg::VARCHAR || to_char(l_min,'00') || to_char(l_sec,l_secfmt) || ' ' || substring('EWNS' FROM l_sign FOR 1);
END
$body$
LANGUAGE plpgsql IMMUTABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_featureExtents( feat_id INTEGER, margin FLOAT )
RETURNS GEOMETRY
AS
$body$
WITH g(geom) AS
(
SELECT
    ST_SetSRID(
       Box2D(
        ST_Collect(ARRAY[
            (SELECT ST_SetSRID(ST_Extent( shape),4167) FROM feature_geometry WHERE feat_id=$1),
            (SELECT ST_SetSRID(ref_point,4167) FROM feature WHERE feat_id=$1)
        ])
        )
    ,4167)
)
SELECT
    CASE WHEN ST_Contains(ST_SetSRID(ST_MakeBox2D(ST_Point(140,-60),ST_Point(210,-20)),4167),geom)
    THEN
    ST_Transform(
        ST_Expand(
            ST_Transform(geom,2193)
       ,$2),
    4167)
    ELSE 
      ST_Intersection(
       ST_SetSRID(ST_MakeBox2D(ST_Point(-10,-90),ST_Point(270,90)),4167),
       ST_Expand(geom,$2/100000.0) -- 100000 is approx metres to degrees
       )
    END
    FROM
       g;
$body$
LANGUAGE sql STABLE
SET search_path FROM CURRENT;

CREATE OR REPLACE FUNCTION gaz_createNewFeature( 
    p_name VARCHAR,
    p_type VARCHAR,
    p_pointwkt VARCHAR ) 
RETURNS INTEGER
AS
$body$
DECLARE v_feat_id INTEGER;
BEGIN
   INSERT INTO feature (feat_type, status, description, ref_point )
   VALUES (p_type, 'CURR', '', ST_PointFromText( p_pointwkt, 4167 ) );
   v_feat_id=lastval();
   INSERT INTO name (feat_id, name, status )
   VALUES (v_feat_id, p_name, 'UNEW' );
   RETURN lastval();
END
$body$
LANGUAGE plpgsql
SET search_path FROM CURRENT;

GRANT EXECUTE ON FUNCTION gaz_plainText( text ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_textHasMacrons( string TEXT ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_plainText2( text ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_plainTextWords( text ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_canDeleteSystemCode(CHAR(4), CHAR(4)) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_nameRelationshipIsTwoWay( VARCHAR(4)) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_featureRelationshipIsTwoWay( VARCHAR(4)) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_preferredNameId( INT ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_preferredName( INT ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_nameTerritorialAuthority( INT ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_degreesToDms( FLOAT, INT, VARCHAR ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_featureExtents( INT, FLOAT ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_createNewFeature( VARCHAR, VARCHAR, VARCHAR ) TO gazetteer_user;

