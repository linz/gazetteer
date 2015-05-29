-- Script to do post load checks on data consistency ...

set search_path=gazetteer_import, gazetteer, public;
set search_path=gazetteer_import, gazetteer, public;

-- update data set feat_id=feat_id_src
-- update gis set feat_id=feat_id_src

DROP TABLE IF EXISTS tmp_name_feat_id;

CREATE TEMP TABLE tmp_name_feat_id AS
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

CREATE TEMP TABLE tmp_multifeat_names AS
SELECT 
     tn.id,
     tn.plain_name,
     n.feat_id,
     tn.feat_type,
     d.src
     -- ,     ST_Transform( fp.geom, 2193 ) as point
FROM 
     tmp_name_feat_id tn
     JOIN tmp_name n ON n.id = tn.id
     JOIN data d ON d.id = tn.id
     LEFT OUTER JOIN tmp_feat_point fp ON fp.feat_id = n.feat_id AND fp.isreal
    JOIN (SELECT plain_name, feat_type FROM tmp_name_feat_id GROUP BY plain_name, feat_type HAVING COUNT(DISTINCT feat_id) > 1) mf
     ON tn.plain_name = mf.plain_name and tn.feat_type = mf.feat_type;

DROP TABLE tmp_name_feat_id;

CREATE INDEX tmp_multifeat_names_name ON tmp_multifeat_names( plain_name, feat_type );
--CREATE INDEX tmp_multifeat_names_point ON tmp_multifeat_names USING GIST(point);
ANALYZE   tmp_multifeat_names;


DROP TABLE IF EXISTS tmp_duplicate_feats;
CREATE TABLE tmp_duplicate_feats AS
WITH tdf (feat_id_1,feat_id_2,plain_name,feat_type,mindist) AS
(
SELECT 
  DISTINCT
   f1.feat_id as feat_id_1,
   f2.feat_id as feat_id_2,
   f1.plain_name,
   f1.feat_type,
   min(ST_Distance_sphere(g1.geom, g2.geom ))
FROM
   tmp_multifeat_names f1
   join tmp_feat_gis g1 on g1.feat_id=f1.feat_id,
   tmp_multifeat_names f2
   join tmp_feat_gis g2 on g2.feat_id=f2.feat_id
WHERE
   f1.plain_name = f2.plain_name AND
   f1.feat_type = f2.feat_type AND
   f1.feat_id < f2.feat_id
GROUP BY 1,2,3,4
)
SELECT
   tdf.feat_id_1,
   tdf.feat_id_2,
   tdf.plain_name,
   tdf.feat_type,
   tdf.mindist,
   array_agg( distinct (d1.src || '(' || d1.lineno::varchar || ')') ) as ids1,
   array_agg( distinct (d2.src || '(' || d2.lineno::varchar || ')') ) as ids2
FROM
   tdf
   JOIN data d1 ON d1.feat_id = tdf.feat_id_1
   JOIN data d2 ON d2.feat_id = tdf.feat_id_2
GROUP BY
   1, 2, 3, 4, 5;

-- select * from tmp_duplicate_feats

DROP TABLE IF EXISTS tmp_merge_feat_ids;
CREATE TEMP TABLE tmp_merge_feat_ids
AS
SELECT
   distinct 
   feat_id_1,
   feat_id_2
FROM 
   tmp_duplicate_feats
WHERE
   array_to_string(ids1,',') ~ 'NZON' AND
   array_to_string(ids2,',') ~ E'^\\s*NZRN\\(\\d+\\)\\s*$' AND
   mindist < 5000;
 
-- Merge features duplicates from ANON and ANXN tables

INSERT INTO tmp_merge_feat_ids
SELECT
   distinct 
   feat_id_1,
   feat_id_2
FROM 
   tmp_duplicate_feats
WHERE
   array_to_string(ids2,',') ~ 'ANON' AND
   array_to_string(ids1,',') ~ E'^\\s*ANXN\\(\\d+\\)\\s*$' AND
   mindist < 5000;
   

delete from tmp_merge_feat_ids WHERE
feat_id_2 IN (SELECT feat_id_2 FROM tmp_merge_feat_ids GROUP BY feat_id_2 HAVING count(*) > 1);

UPDATE data 
SET feat_id=(select feat_id_1 FROM tmp_merge_feat_ids WHERE feat_id_2=data.feat_id)
WHERE feat_id IN (select feat_id_2 from tmp_merge_feat_ids);

UPDATE gis 
SET feat_id=(select feat_id_1 FROM tmp_merge_feat_ids WHERE feat_id_2=gis.feat_id)
WHERE feat_id IN (select feat_id_2 from tmp_merge_feat_ids);

-- select name, gaz_plaintext(name) from data where feat_id=11479
-- select * from tmp_duplicate_feats order by mindst

DELETE FROM error WHERE class='FEAT' and subclass='MRGF';
DELETE FROM error_class WHERE class='FEAT' and subclass='MRGF';

INSERT INTO error_class( class, subclass, description, idtype, info )
VALUES ('FEAT','MRGF','Info only: features merged (two entries).','FEAT', 'Y');

INSERT INTO error( id, class, subclass, error )
SELECT 
   tdf.feat_id_1,
   'FEAT',
   'MRGF',
   'Info only: Merging features ' || 
   array_to_string(ids1,',') || ': ' || array_to_string(ids2,',')|| ':' ||
   tdf.feat_id_1::varchar || ': ' || tdf.feat_id_2::varchar ||
   ': Features with same name (' || tdf.plain_name || ') and feature type (' || 
    tdf.feat_type || ') within ' || mindist::int::varchar || ' metres of each other'
FROM
   tmp_duplicate_feats tdf
   JOIN tmp_merge_feat_ids tm ON tm.feat_id_1=tdf.feat_id_1 AND tm.feat_id_2=tdf.feat_id_2;

INSERT INTO error( id, class, subclass, error )
SELECT 
   tdf.feat_id_2,
   'FEAT',
   'MRGF',
   'Info only: Merging features ' || 
   array_to_string(ids1,',') || ': ' || array_to_string(ids2,',')|| ':' ||
   tdf.feat_id_1::varchar || ': ' || tdf.feat_id_2::varchar ||
   ': Features with same name (' || tdf.plain_name || ') and feature type (' || 
    tdf.feat_type || ') within ' || mindist::int::varchar || ' metres of each other'
FROM
   tmp_duplicate_feats tdf
   JOIN tmp_merge_feat_ids tm ON tm.feat_id_1=tdf.feat_id_1 AND tm.feat_id_2=tdf.feat_id_2;

DROP TABLE tmp_merge_feat_ids;
DROP Table tmp_multifeat_names;
DROP TABLE tmp_duplicate_feats;

