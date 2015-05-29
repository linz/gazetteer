-- Script to do post load checks on data consistency ...

set search_path=gazetteer_import, gazetteer, gazetteer_web, public;
set search_path=gazetteer_import, gazetteer, gazetteer_web, public;

DROP TABLE IF EXISTS tmp_name_feat_id;

CREATE TABLE tmp_name_feat_id AS
SELECT 
   n.id,
   n.feat_id,
   f.ftype_code as feat_type,
   -- lower(gaz_plaintext(n.name)) plain_name
   lower(name) as plain_name
FROM
   tmp_name n
   JOIN tmp_feat_type f ON f.feat_id = n.feat_id;

CREATE INDEX tmp_name_feat_id_name ON tmp_name_feat_id( plain_name, feat_type );

DROP TABLE IF EXISTS tmp_multifeat_names;

CREATE TABLE tmp_multifeat_names AS
SELECT 
     tn.id,
     tn.plain_name,
     n.feat_id,
     tn.feat_type,
     d.src,
     ST_Transform( fp.geom, 2193 ) as point
FROM 
     tmp_name_feat_id tn
     JOIN tmp_name n ON n.id = tn.id
     JOIN data d ON d.id = tn.id
     LEFT OUTER JOIN tmp_feat_point fp ON fp.feat_id = n.feat_id AND fp.isreal
    JOIN (SELECT plain_name, feat_type FROM tmp_name_feat_id GROUP BY plain_name, feat_type HAVING COUNT(DISTINCT feat_id) > 1) mf
     ON tn.plain_name = mf.plain_name and tn.feat_type = mf.feat_type;

DROP TABLE tmp_name_feat_id;

CREATE INDEX tmp_multifeat_names_name ON tmp_multifeat_names( plain_name, feat_type );
CREATE INDEX tmp_multifeat_names_point ON tmp_multifeat_names USING GIST(point);
ANALYZE tmp_multifeat_names;

SELECT
   plain_name,
   feat_type,
   array_to_string(array_agg(src || ': ' || nfeat::varchar),', ')
FROM
   (SELECT
      plain_name,
      feat_type,
      src,
      COUNT(DISTINCT feat_id) AS nfeat
    FROM
      tmp_multifeat_names
    GROUP BY
      plain_name, feat_type, src
    ) tm
GROUP BY
    plain_name,
    feat_type
ORDER BY
    SUM(nfeat) DESC;
    
CREATE OR REPLACE FUNCTION tmp_spatial_merge_feat( p_range double precision )
RETURNS INT
AS
$code$
DECLARE
BEGIN
    DROP TABLE IF EXISTS tmp_bb1;
    
    CREATE TEMP TABLE tmp_bb1 AS
    SELECT plain_name, feat_type, ST_Expand(point, p_range) as bbox
    FROM tmp_multifeat_names;

    CREATE INDEX tmp_bb1_i1 ON tmp_bb1(plain_name, feat_type);
    ANALYZE tmp_bb1;

    DROP TABLE IF EXISTS tmp_bb2;
    CREATE TEMP TABLE tmp_bb2 AS
    SELECT plain_name, feat_type, ST_Union(bbox) as geom
    FROM tmp_bb1
    GROUP BY plain_name, feat_type;

    DROP TABLE IF EXISTS tmp_bb3;
    CREATE TEMP TABLE tmp_bb3 AS 
    SELECT plain_name, feat_type, ST_GeometryN(geom, generate_series(1, ST_NumGeometries(geom))) as geom
    FROM tmp_bb2
    WHERE ST_NumGeometries(geom) IS NOT NULL; 

    INSERT INTO tmp_bb3
    SELECT plain_name, feat_type, geom
    FROM tmp_bb2
    WHERE ST_NumGeometries(geom) IS NULL;

    DROP TABLE IF EXISTS tmp_bb4;
    --CREATE TEMP TABLE tmp_bb4 AS
    CREATE TABLE tmp_bb4 AS
    SELECT 
       n.plain_name,
       n.feat_type,
       MIN(n.feat_id) as merge_feat_id,
       COUNT(n.feat_id) as nmerged,
       b.geom
    FROM
       tmp_multifeat_names n
       JOIN tmp_bb3 b ON n.plain_name=b.plain_name and n.feat_type=b.feat_type
    WHERE
       ST_Contains(b.geom,n.point)
    GROUP BY
       n.plain_name,
       n.feat_type,
       b.geom; 

     DROP TABLE IF EXISTS tmp_feat_merge;
     CREATE TABLE tmp_feat_merge AS
     SELECT 
        n.feat_id,
        b.merge_feat_id
     FROM       
       tmp_multifeat_names n
       JOIN tmp_bb4 b ON n.plain_name=b.plain_name and n.feat_type=b.feat_type
    WHERE
       ST_Contains(b.geom,n.point);
    CREATE INDEX tmp_feat_merge_feat_id  ON tmp_feat_merge( feat_id );
    ANALYZE tmp_feat_merge;

    

    
       

    return (SELECT SUM(COALESCE(ST_NumGeometries(geom),1)) FROM tmp_bb2);
END
$code$
LANGUAGE plpgsql;



SELECT tmp_spatial_merge_feat(90000.0);
SELECT COUNT(*) FROM tmp_bb3;
SELECT ST_GeometryType(geom) from tmp_bb2;

-- SELECT * FROM data WHERE id IN (SELECT id FROM tmp_multifeat_names WHERE plain_name='waipapa stream') order by crd_north DESC;
--select * from spatial_ref_sys where srid in (4167,2193);

--CREATE TABLE tmp_feat_geom_count AS
--SELECT DISTINCT(ST_GeometryType(geom)) FROM tmp_feat_geom WHERE ST_NumGeometries(geom) IS NOT NULL;

-- SELECT COUNT(DISTINCT feat_id) FROM tmp_feat_geom;
-- SELECT COUNT(DISTINCT feat_id) FROM tmp_feat_point where isreal;

select distinct plain_name, feat_type from tmp_multifeat_names;
select count(*) from tmp_multifeat_names;
