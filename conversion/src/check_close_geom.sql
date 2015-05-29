-- Script to do post load checks on data consistency ...

set search_path=gazetteer_import, gazetteer, public;
set search_path=gazetteer_import, gazetteer, public;


DROP TABLE IF EXISTS tmp_name_feat_id;

-- Work with a copy of tmp_feat_gis, excluding duplicate lat/lon and prj records

DROP TABLE IF EXISTS tmp_feat_gis_delprj;

CREATE TEMP TABLE tmp_feat_gis_delprj
AS 
SELECT
   g1.gid
FROM 
   tmp_feat_gis g1 
   JOIN tmp_feat_gis g2 ON g1.feat_id=g2.feat_id
WHERE
   g1.src=g2.src AND
   g1.srcid=g2.srcid AND
   g1.gsrc='FPrjCrd' AND
   g2.gsrc='FLatLon';
   

CREATE INDEX idx_tmpdelprj_gid ON tmp_feat_gis_delprj( gid );
ANALYZE tmp_feat_gis_delprj;

DROP TABLE IF EXISTS tmp_feat_giscg;

CREATE TEMP TABLE tmp_feat_giscg
AS
SELECT
  g1.gid,
  g1.id,
  g1.gsrc,
  g1.feat_id,
  g1.srid,
  g1.src,
  g1.srcid,
  g1.geom
FROM
  tmp_feat_gis g1
  LEFT OUTER JOIN tmp_feat_gis_delprj td ON td.gid = g1.gid
WHERE
  td.gid IS NULL;

CREATE INDEX idx_tmp_feat_giscg_feat_id ON tmp_feat_giscg( feat_id );
CREATE INDEX idx_tmp_feat_giscg_src ON tmp_feat_giscg( gsrc, id );
CREATE INDEX idx_tmp_feat_giscg_gid ON tmp_feat_giscg( gid );

ANALYZE tmp_feat_giscg;

DROP TABLE IF EXISTS tmp_feat_gis_delprj;


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
     -- , ST_Transform( fp.geom, 2193 ) as point
FROM 
     tmp_name_feat_id tn
     JOIN tmp_name n ON n.id = tn.id
     JOIN data d ON d.id = tn.id
     LEFT OUTER JOIN tmp_feat_point fp ON fp.feat_id = n.feat_id and fp.isreal
    JOIN (SELECT plain_name, feat_type FROM tmp_name_feat_id GROUP BY plain_name, feat_type HAVING COUNT(DISTINCT feat_id) > 1) mf
     ON tn.plain_name = mf.plain_name and tn.feat_type = mf.feat_type;

DROP TABLE tmp_name_feat_id;

CREATE INDEX tmp_multifeat_names_name ON tmp_multifeat_names( plain_name, feat_type );
-- CREATE INDEX tmp_multifeat_names_point ON tmp_multifeat_names USING GIST(point);
ANALYZE tmp_multifeat_names;


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
   join tmp_feat_giscg g1 on g1.feat_id=f1.feat_id,
   tmp_multifeat_names f2
   join tmp_feat_giscg g2 on g2.feat_id=f2.feat_id
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

ALTER TABLE tmp_duplicate_feats add column id serial primary key;

ANALYZE tmp_duplicate_feats;

-- select name, gaz_plaintext(name) from data where feat_id=11479
-- select * from tmp_duplicate_feats order by mindist

DELETE FROM error WHERE class='FEAT' and subclass='DUPF';
DELETE FROM error_class WHERE class='FEAT' and subclass='DUPF';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FEAT','DUPF','Two features with the same name and type within 5km (two entries each)','FEAT');

INSERT INTO error( id, class, subclass, error )
SELECT 
   feat_id_1,
   'FEAT',
   'DUPF',
   array_to_string(ids1,',') || ': ' || array_to_string(ids2,',')|| ':' ||
   feat_id_1::varchar || ': ' || feat_id_2::varchar ||
   ': Features with same name (' || tdf.plain_name || ') and feature type (' || 
    tdf.feat_type || ') within ' || mindist::int::varchar || ' metres of each other'
FROM
   tmp_duplicate_feats tdf
WHERE
   mindist < 5000;

INSERT INTO error( id, class, subclass, error )
SELECT 
   feat_id_2,
   'FEAT',
   'DUPF',
   array_to_string(ids1,',') || ': ' || array_to_string(ids2,',')|| ':' ||
   feat_id_1::varchar || ': ' || feat_id_2::varchar ||
   ': Features with same name (' || tdf.plain_name || ') and feature type (' || 
    tdf.feat_type || ') within ' || mindist::int::varchar || ' metres of each other'
FROM
   tmp_duplicate_feats tdf
WHERE
   mindist < 5000;

DROP Table tmp_multifeat_names;
--DROP TABLE tmp_duplicate_feats;

-- SELECT * FROM error WHERE class='FEAT' AND subclass='DUPF';
-- SELECT * from tmp_duplicate_feats 

-- Look for feature that have inconsistent geometries - too big...

CREATE OR REPLACE FUNCTION quantile(p_arr anyarray,p_prob float8)
   RETURNS float8 AS
$$ 
  WITH v(val) AS
  (
     SELECT val::float8
     FROM unnest($1) val
     WHERE val IS NOT NULL
  ),
  c1(pn) AS
  (
     SELECT (count(*)-1)*greatest(0.0,least(1.0,$2)) FROM v
  ),
  c2(offs,fact) AS
  (
     SELECT floor(pn)::int, pn-floor(pn) FROM c1
  )
  SELECT MAX(val)*(select fact from c2)+MIN(val)*(select 1-fact from c2)
  FROM
    (SELECT val
     FROM v
     ORDER BY val
     OFFSET (select offs FROM c2)
     LIMIT 2) v2
$$
LANGUAGE 'sql' IMMUTABLE;

DROP TABLE IF EXISTS tmp_feat_extents;
CREATE TABLE tmp_feat_extents AS
WITH fe0( feat_id, geom, ftype_code ) AS
(
SELECT
   g.feat_id,
   st_extent(g.geom),
   ft.ftype_code
FROM
   tmp_feat_giscg g
    left outer join tmp_feat_type ft on ft.feat_id=g.feat_id
GROUP BY
   g.feat_id, ft.ftype_code
),
fe( feat_id, ftype_code, extent ) AS
(
SELECT
    feat_id,
    ftype_code,
	CASE  st_geometrytype(fe0.geom) WHEN 'ST_Point' THEN
	      0.0
	   WHEN 'ST_LineString' THEN
	      ST_Length_Spheroid( geom, 'SPHEROID["GRS_1980",6378137,298.257222101]' )
	   ELSE
	      round(st_distance_sphere(st_pointn(st_exteriorring(fe0.geom),1),st_pointn(st_exteriorring(fe0.geom),3))/10)/100::float
	   END
FROM
    fe0
    ),
ft0( feat_id, gtype, gcount) AS
(
SELECT
   feat_id,
   GeometryType(geom),
   count(*)
from tmp_feat_giscg
group by feat_id, GeometryType(geom)
),
ft1( feat_id, gtypes ) AS
(
SELECT
   feat_id,
   array_to_string(array_agg( gtype || '(' || gcount::varchar || ')' ),' ')
FROM
   ft0
GROUP BY
   feat_id
)
,
gs0( feat_id, src, scount) AS
(
SELECT
   feat_id,
   src,
   count(*)
from tmp_feat_giscg
group by feat_id, src
),
gs1( feat_id, srcs ) AS
(
SELECT
   feat_id,
   array_to_string(array_agg( src || '(' || scount::varchar || ')' ),' ')
FROM
   gs0
GROUP BY
   feat_id
),
fq0 ( ftype_code, extent95pc )
as 
(
select
   ftype_code,
   quantile(array_agg(extent),0.95)
from 
   fe
where
   extent > 0
group by 
   ftype_code
)
SELECT
   fe.feat_id, 
   (select array_to_string(array_agg(distinct lower(gaz_plaintext(name))),'; ') from tmp_name tn where tn.feat_id=fe.feat_id) as name,
   fe.ftype_code,
   ft1.gtypes,
   gs1.srcs,
   fe.extent,
   fq0.extent95pc
FROM
   fe
   join ft1 on ft1.feat_id=fe.feat_id
   join gs1 on gs1.feat_id=fe.feat_id
   left outer join fq0 on fq0.ftype_code=fe.ftype_code
   ;


DELETE FROM error WHERE class='FEAT' and subclass='GEOX';
DELETE FROM error_class WHERE class='FEAT' and subclass='GEOX';

INSERT INTO error_class( class, subclass, description, idtype, info )
VALUES ('FEAT','GEOX','Feature geometries appear too big - possible mis-identification or mis-location', 'FEAT', 'Y');

INSERT INTO error( id, class, subclass, error )
SELECT 
   fe.feat_id,
   'FEAT',
   'GEOX',
   feat_id::varchar || ':' || fe.srcs || ': ' || coalesce(fe.name,'unnamed') ||  ': Feature spans ' || round(fe.extent::numeric,1)::varchar || 'km, atypical for type ' || sc.value || ', expect < ' || round((extent95pc*4.0)::numeric,1)::varchar
FROM
   tmp_feat_extents fe
   join system_code sc on sc.code_group='FTYP' and sc.code=fe.ftype_code
WHERE
   fe.extent > fe.extent95pc*4.0;

-- select *, extent/threshold from tmp_feat_extents  where extent > threshold*3 order by extent/threshold desc;
-- select ftype_code, sc.value, max(extent) as max_extent, count(*) from tmp_feat_extents fe join system_code sc on sc.code_group='FTYP' and sc.code=fe.ftype_code where extent > 0 group by ftype_code, sc.value order by max_extent desc
-- select * from error where class='FEAT' and subclass='GEOX'
