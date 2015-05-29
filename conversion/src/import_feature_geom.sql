
-- Script to load features geometries from import data
-- (GIS tables first set up with load_gis_data.py)

SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET client_min_messages=WARNING;

drop table if exists tmp_feat_gis;
create table tmp_feat_gis
(
    gid SERIAL NOT NULL PRIMARY KEY,
    id INTEGER NOT NULL,
    gsrc varchar(10) NOT NULL,
    feat_id INTEGER NOT NULL,
    srid INTEGER NOT NULL,
    src CHAR(4) not null default '',
    srcid INTEGER not null default 0,
    geom GEOMETRY NOT NULL
);

CREATE INDEX tfg_src ON tmp_feat_gis( gsrc, id );
CREATE INDEX tfg_fid ON tmp_feat_gis( feat_id );

-- Create projection coordinate points

INSERT INTO tmp_feat_gis( id, gsrc, feat_id, srid, src, srcid, geom )
SELECT
    d.id,
    'FPrjCrd',
    d.feat_id,
    p.srid,
    d.src,
    d.lineno,
    ST_Point( crd_east, crd_north )
FROM 
    data d
    join crdsys_srid p ON p.cscode = d.crd_projection AND p.isproj
WHERE
    d.feat_id IS NOT NULL AND
    d.crd_east IS NOT NULL AND 
    d.crd_north IS NOT NULL
    ;
    
-- Create latitude/longitude points

INSERT INTO tmp_feat_gis( id, gsrc, feat_id, srid, src, srcid, geom )
SELECT
    d.id,
    'FLatLon',
    d.feat_id,
    p.srid,
    d.src,
    d.lineno,
    ST_Point( latlon_angle(crd_longitude), latlon_angle(crd_latitude) )
FROM 
    data d
    join crdsys_srid p ON p.cscode = d.crd_datum AND NOT p.isproj
WHERE
    d.feat_id IS NOT NULL AND
    latlon_angle(crd_longitude) IS NOT NULL AND 
    latlon_angle(crd_latitude) IS NOT NULL
    ;

-- Missing datum - assume NZGD2000
   
INSERT INTO tmp_feat_gis( id, gsrc, feat_id, srid, src, srcid, geom )
SELECT
    d.id,
    'FLatLonND',
    d.feat_id,
    p.srid,
    d.src,
    d.lineno,
    ST_Point( latlon_angle(crd_longitude), latlon_angle(crd_latitude) )
FROM 
    data d,
    crdsys_srid p
WHERE
    d.feat_id IS NOT NULL AND
    d.id NOT IN (SELECT id FROM tmp_feat_gis WHERE gsrc='FLatLon') AND
    latlon_angle(crd_longitude) IS NOT NULL AND 
    latlon_angle(crd_latitude) IS NOT NULL AND
    p.cscode = 'NZGD2000'
    ;
    
-- Latitude/longitude point arrays ... 

INSERT INTO tmp_feat_gis( id, gsrc, feat_id, srid, src, srcid, geom )
SELECT
    d.id,
    'FLatLonAr',
    d.feat_id,
    p.srid,
    d.src,
    d.lineno,
    latlon_geometry( d.geom_type, d.crd_longitude, d.crd_latitude )
FROM 
    data d
    join crdsys_srid p ON p.cscode = d.crd_datum AND NOT p.isproj
WHERE
    d.feat_id IS NOT NULL AND
    d.id NOT IN (SELECT id FROM tmp_feat_gis WHERE gsrc like 'FLatLon%') AND
    d.crd_latitude IS NOT NULL AND
    d.crd_longitude IS NOT NULL AND
    d.geom_type IS NOT NULL AND
    latlon_geometry( d.geom_type, d.crd_longitude, d.crd_latitude ) IS NOT NULL
    ;

-- Geometries from Arc 

INSERT INTO tmp_feat_gis( id, gsrc, feat_id, srid, src, srcid, geom )
SELECT
   g.id,
   'GIS',
   g.feat_id,
   g.srid,
   g.src,
   g.srcno,
   g.geom
FROM
   gis g;

UPDATE tmp_feat_gis SET geom=ST_SetSrid(geom,srid);

ANALYZE tmp_feat_gis;

-- SELECT gsrc, count(*) from tmp_feat_gis group by gsrc; 
-- SELECT DISTINCT crd_datum FROM data;
-- SELECT * FROM data WHERE crd_datum='CRD';


DELETE FROM error WHERE class='FGEO' AND subclass='ENMS';
DELETE FROM error_class WHERE class='FGEO' AND subclass='ENMS';

INSERT INTO error_class( class, subclass, description )
VALUES ('FGEO','ENMS','Projection coordinates have missing east or north components');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'FGEO',
   'ENMS',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Projection coordinates have missing components'
FROM
   data d
WHERE 
  feat_id IS NOT NULL AND
 (crd_east IS NOT NULL OR crd_north IS NOT NULL) AND
 (crd_projection IS NULL OR crd_east IS NULL OR crd_north IS NULL);


DELETE FROM error WHERE class='FGEO' AND subclass='ENBD';
DELETE FROM error_class WHERE class='FGEO' AND subclass='ENBD';

INSERT INTO error_class( class, subclass, description )
VALUES ('FGEO','ENBD','Projection coordinates cannot be used (invalid coordsys?)');
 
INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'FGEO',
   'ENBD',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Projection coordinates cannot be used'
FROM
   data d
   LEFT OUTER JOIN tmp_feat_gis g ON g.gsrc='FPrjCrd' AND g.id=d.id
WHERE 
  d.feat_id IS NOT NULL AND
  (d.crd_east IS NOT NULL AND d.crd_north IS NOT NULL) AND
  g.id IS NULL;

-- Incomplete lat/lon coordinate information

DELETE FROM error WHERE class='FGEO' AND subclass='LLND';
DELETE FROM error_class WHERE class='FGEO' AND subclass='LLND';

INSERT INTO error_class( class, subclass, description, info )
VALUES ('FGEO','LLND','Latitude longitudes do not have datum (NZGD2000 assumed)','Y');
 

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'FGEO',
   'LLND',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Lat/lon datum assumed to be NZGD2000'
FROM
   data d
WHERE
   d.feat_id IS NOT NULL AND
   d.id IN (SELECT id FROM tmp_feat_gis WHERE gsrc like 'FLatLon%') AND
   d.crd_datum IS NULL;

DELETE FROM error WHERE class='FGEO' AND subclass='LLMS';
DELETE FROM error_class WHERE class='FGEO' AND subclass='LLMS';

INSERT INTO error_class( class, subclass, description )
VALUES ('FGEO','LLMS','Latitude longitudes incomplete');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'FGEO',
   'LLMS',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Lat/lon data incomplete'   
FROM
   data d 
WHERE
   d.feat_id IS NOT NULL AND
   (crd_latitude IS NOT NULL OR crd_longitude IS NOT NULL) AND
   (crd_datum IS NULL OR crd_latitude IS NULL OR crd_longitude IS NULL) AND
   d.id NOT IN (SELECT id FROM tmp_feat_gis WHERE gsrc like 'FLatLon%');


DELETE FROM error WHERE class='FGEO' AND subclass='LLBD';
DELETE FROM error_class WHERE class='FGEO' AND subclass='LLBD';

INSERT INTO error_class( class, subclass, description )
VALUES ('FGEO','LLBD','Latitude longitudes badly formatted - could not be used');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'FGEO',
   'LLBD',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Lat/lon data invalid'   
FROM
   data d 
   LEFT OUTER JOIN tmp_feat_gis t ON t.gsrc LIKE 'FLatLon%' AND t.id=d.id
WHERE
   d.feat_id IS NOT NULL AND
   (crd_datum IS NOT NULL AND crd_latitude IS NOT NULL AND crd_longitude IS NOT NULL) AND
   t.id IS NULL;

DELETE FROM error WHERE class='FGEO' AND subclass='GSBF';
DELETE FROM error_class WHERE class='FGEO' AND subclass='GSBF';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FGEO','GSBF','Feature id in GIS data but not in spreadsheet data','FEAT');

INSERT INTO error( id, class, subclass, error )
SELECT 
   g.feat_id,
   'FGEO',
   'GSBF',
   g.id::VARCHAR || ': ' || g.feat_id::VARCHAR(20) || ': ' || COALESCE(g.name,'') || ': GIS feature id not in spreadsheet data'
FROM
   gis g 
   LEFT OUTER JOIN data d ON d.feat_id=g.feat_id
WHERE
   d.feat_id IS NULL;

-- ----------------------------------------------------------------

CREATE OR REPLACE FUNCTION tmp_normalize_names( name VARCHAR )
RETURNS VARCHAR
AS
$body$
   SELECT 
     array_to_string(array_agg(word),' ')
   from
	(select
	   replace(word,'mountain','mount') as word
	 from
	   regexp_split_to_table(
		     lower(trim(gaz_plaintext($1))),
		     E'[^\\w]+') as word
	 order by word) as words
$body$ LANGUAGE SQL;

DELETE FROM error WHERE class='FGEO' AND subclass='GSNM';
DELETE FROM error_class WHERE class='FGEO' AND subclass='GSNM';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FGEO','GSNM','Feature name in GIS data doesn''t match spreadsheet','FEAT');

INSERT INTO error( id, class, subclass, error )
SELECT 
   g.feat_id,
   'FGEO',
   'GSNM',
   g.id::VARCHAR || ': ' || g.feat_id::VARCHAR(20) || ': ' || COALESCE(g.name,'') || ': ' ||
   (select array_to_string(array_agg(name || ' (' || src || ')'),', ') from data where feat_id=g.feat_id and name is not null) || ': ' ||
   'GIS feature name doesn''t match spreadsheet name'
FROM
   gis g
   LEFT OUTER JOIN data d on d.feat_id=g.feat_id 
      AND tmp_normalize_names(d.name)=tmp_normalize_names(g.name)
WHERE
   g.name IS NOT NULL AND g.name <> '' AND
   g.feat_id IN (SELECT feat_id FROM data) AND
   d.id IS NULL;

DROP FUNCTION tmp_normalize_names( VARCHAR );

DELETE FROM error WHERE class='FGEO' AND subclass='NOGM';
DELETE FROM error_class WHERE class='FGEO' AND subclass='NOGM';

INSERT INTO error_class( class, subclass, description )
VALUES ('FGEO','NOGM','Cannot find geometry for feature in spreadsheets or GIS data');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'FGEO',
   'NOGM',
    d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || d.feat_id::VARCHAR(20) || ': Feature has no geometry'
FROM
   data d
   LEFT OUTER JOIN tmp_feat_gis g ON g.feat_id = d.feat_id
WHERE
   d.feat_id IS NOT NULL AND
   g.feat_id IS NULL;

-- Check coordinates are in valid ranges for projections
-- Then delete geometries where out of range as will not translate to 4167

DROP TABLE IF EXISTS tmp_outofrange;
CREATE TEMP TABLE tmp_outofrange
AS
SELECT
   g.gid
FROM
   tmp_feat_gis g
   join crdsys_srid cs on cs.srid = g.srid
WHERE
   NOT ST_Contains(cs.extents, g.geom)
   AND cs.isproj;

DELETE FROM error WHERE class='FGEO' AND subclass='PCOR';
DELETE FROM error_class WHERE class='FGEO' AND subclass='PCOR';
 

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FGEO','PCOR','Projection coordinates outside valid range', 'FEAT');
   
INSERT INTO error(id, class, subclass, error )
SELECT
   g.feat_id,
   'FGEO',
   'PCOR',
   g.src || ':' || g.srcid || ': Projection coordinates out of range for ' || cs.cscode
         || ' ' || ST_AsText(ST_Centroid(g.geom))
FROM
   tmp_feat_gis g
   join crdsys_srid cs on cs.srid = g.srid
WHERE
   g.gid IN (SELECT gid FROM tmp_outofrange);

DELETE FROM tmp_feat_gis WHERE gid IN (SELECT gid FROM tmp_outofrange);
DROP TABLE tmp_outofrange;

-- Update all geometries to SRID 4167

update tmp_feat_gis
set geom=st_transform(geom,4167);

-- Shift geometries with negative longitudes 

update tmp_feat_gis
set geom=st_translate(geom,360,0)
where st_x(st_centroid(box2d(geom))) < 0;

-- Check geometries have valid latitudes and longitudes

DROP TABLE IF EXISTS tmp_outofrange;
CREATE TEMP TABLE tmp_outofrange
AS
SELECT
   g.gid
FROM
   tmp_feat_gis g
   join crdsys_srid cs on cs.srid = g.srid
WHERE
   NOT ST_Contains(ST_SetSrid(ST_MakeBox2D(ST_Point(90,-90),ST_Point(270,0)),4167),g.geom)
   AND NOT ST_OrderingEquals(geom,ST_SetSrid(ST_Point(0,-90),4167));

DELETE FROM error WHERE class='FGEO' AND subclass='GCOR';
DELETE FROM error_class WHERE class='FGEO' AND subclass='GCOR';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FGEO','GCOR','Geographic coordinates outside valid range', 'FEAT');
   
INSERT INTO error(id, class, subclass, error )
SELECT
   g.feat_id,
   'FGEO',
   'GCOR',
   g.src || ':' || g.srcid || ': Geographic coordinates out of range for ' || cs.cscode
         || ' ' || ST_AsText(ST_Centroid(g.geom))
FROM
   tmp_feat_gis g
   join crdsys_srid cs on cs.srid = g.srid
WHERE
   g.gid IN (SELECT gid FROM tmp_outofrange);

DELETE FROM tmp_feat_gis WHERE gid IN (SELECT gid FROM tmp_outofrange);
DROP TABLE tmp_outofrange;

-- Compare coordinates derived from projection coordinates and lat-lon in the same
-- record.  Tolerance of 150m here - based on plotting differences - this catches
-- just a few extreme recordsrecords.  Bringing down to 100m catches over 500 records...
-- Note: Seems proj coords are commonly rounded to 100m, so errors of 150m in rounded 
-- values are not unreasonable.

DROP TABLE IF EXISTS tmp_prjlldiff;

CREATE TABLE tmp_prjlldiff AS
SELECT 
    g1.src, 
    g1.srcid, 
    g1.feat_id, 
    st_distance_sphere(g1.geom,g2.geom) as diff
FROM 
    tmp_feat_gis g1
    JOIN tmp_feat_gis g2 ON g1.feat_id = g2.feat_id
WHERE 
    g1.gsrc='FPrjCrd' AND g2.gsrc='FLatLon'
    AND g1.src=g2.src
    AND g1.srcid=g2.srcid;

DELETE FROM error WHERE class='FGEO' AND subclass='PLDF';
DELETE FROM error_class WHERE class='FGEO' AND subclass='PLDF';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FGEO','PLDF','Projection/lat long coords differ by more than 150m', 'FEAT');
   
INSERT INTO error(id, class, subclass, error )
SELECT
   g.feat_id,
   'FGEO',
   'PLDF',
   g.src || ':' || g.srcid || ': ' || d.name || 
   ': Projection/lat long coords differ ' || round(g.diff::numeric,1)::varchar ||
   ' (> 150m)'
FROM
   tmp_prjlldiff g
   join data d on d.src=g.src and d.lineno=g.srcid
WHERE
   g.diff > 150.0;

-- select *,round(diff::numeric,1)::varchar from tmp_prjlldiff where diff > 150 order by diff
-- select * from error where class='FGEO' and subclass='PLDF'

DROP TABLE IF EXISTS tmp_prjlldiff;

-- For features within 135 metres want to merge 


-- NOTE: Should probably do some more checks on shapes here .. 
-- consistency of shapes from different data sources.

-- Create table tmp_feat_geom with the shapes from GIS sources converted to NZGD2000
-- Create table tmp_feat_point with a reference point for the feature - currently the midpoint of the bounding box
-- of all representations

drop table if exists tmp_feat_point;
drop table if exists tmp_feat_geom;

create table tmp_feat_geom
(
   id serial primary key,
   feat_id int not null,
   geom geometry
);

create table tmp_feat_point
(
   feat_id int not null primary key,
   geom geometry,
   isreal boolean default TRUE
);

-- Only take shapes from ArcGIS database for the moment 
-- or from lat/long array if that is not defined

insert into tmp_feat_geom (feat_id, geom )
select 
   feat_id,
   geom
from
   tmp_feat_gis
where
   gsrc='GIS' and
   GeometryType(geom) not like 'MULTI%';

insert into tmp_feat_geom (feat_id, geom )
select 
   feat_id,
   ST_GeometryN(geom,generate_series(1,ST_NumGeometries(geom)))
from
   tmp_feat_gis
where
   gsrc='GIS' and
   GeometryType(geom) like 'MULTI%';

create index idx_tmp_feat_geom_feat_id on tmp_feat_geom( feat_id );
analyze tmp_feat_geom;

-- Try for coordinates from official names

insert into tmp_feat_geom (feat_id, geom )
select 
   g.feat_id,
   g.geom
from
   tmp_feat_gis g
   left outer join tmp_name tn on tn.id = g.id
   left outer join tmp_feat_geom t on t.feat_id = g.feat_id
where
   g.gsrc='FLatLonAr'
   AND tn.status LIKE 'O%'
   AND t.feat_id IS NULL;
analyze tmp_feat_geom;

insert into tmp_feat_geom (feat_id, geom )
select 
   distinct
   g.feat_id,
   g.geom
from
   tmp_feat_gis g
   left outer join tmp_name tn on tn.id = g.id
   left outer join tmp_feat_geom t on t.feat_id = g.feat_id
where
   g.gsrc='FLatLon'
   AND tn.status LIKE 'O%'
   AND t.feat_id IS NULL;
analyze tmp_feat_geom;


insert into tmp_feat_geom (feat_id, geom )
select 
   distinct
   g.feat_id,
   g.geom
from
   tmp_feat_gis g
   left outer join tmp_name tn on tn.id = g.id
   LEFT OUTER JOIN tmp_feat_geom t on t.feat_id = g.feat_id
where
   g.gsrc='FPrjCrd'
   AND tn.status LIKE 'O%'
   AND t.feat_id IS NULL;
analyze tmp_feat_geom;

-- Still nothing - try for any coordinates...

insert into tmp_feat_geom (feat_id, geom )
select 
   g.feat_id,
   g.geom
from
   tmp_feat_gis g
   left outer join tmp_feat_geom t on t.feat_id = g.feat_id
where
   g.gsrc='FLatLonAr'
   AND t.feat_id IS NULL;
analyze tmp_feat_geom;

insert into tmp_feat_geom (feat_id, geom )
select 
   distinct
   g.feat_id,
   g.geom
from
   tmp_feat_gis g
   left outer join tmp_feat_geom t on t.feat_id = g.feat_id
where
   g.gsrc='FLatLon'
   AND t.feat_id IS NULL;
analyze tmp_feat_geom;


insert into tmp_feat_geom (feat_id, geom )
select 
   distinct
   g.feat_id,
   g.geom
from
   tmp_feat_gis g
   LEFT OUTER JOIN tmp_feat_geom t on t.feat_id = g.feat_id
where
   g.gsrc='FPrjCrd'
   AND t.feat_id IS NULL;
analyze tmp_feat_geom;

-- Check for duplicated geometries

delete from tmp_feat_geom where id in
(
select
   distinct
   tg2.id
from
   tmp_feat_geom tg1
   join tmp_feat_geom tg2 on tg1.feat_id=tg2.feat_id and tg1.id < tg2.id
where
   st_equals(tg1.geom,tg2.geom)
);

-- Where features have a single point type (even if they have other geometry
-- types), replace this point with the feature ref_point

drop table if exists tmp_refpoint_geomid;
create temp table tmp_refpoint_geomid AS
select 
    feat_id,
    min(id) as id
from 
    tmp_feat_geom
where
    GeometryType(geom) = 'POINT'
group by 
    feat_id
having
    count(*) = 1;

create index tmp_refpoint_geomid_feat_id on tmp_refpoint_geomid( feat_id );
create index tmp_refpoint_geomid_id on tmp_refpoint_geomid( id );
analyse tmp_refpoint_geomid;

delete from tmp_feat_point;

insert into tmp_feat_point( feat_id, geom )
select
  gis.feat_id,
  st_setsrid( geom, 4167)
from
  tmp_feat_geom gis
  join tmp_refpoint_geomid rp on gis.id = rp.id;

delete from tmp_feat_geom
where id in (select id from tmp_refpoint_geomid);

-- Create the reference point for other features based on the centroid of their extents.

insert into tmp_feat_point( feat_id, geom )
select
  g.feat_id,
  st_closestpoint(
    st_setsrid( st_collect(g.geom), 4167),
    st_setsrid( st_centroid(st_extent(g.geom)), 4167)
    )
from
  tmp_feat_geom g
  LEFT OUTER JOIN tmp_refpoint_geomid t ON t.feat_id=g.feat_id
where
  t.feat_id IS NULL
group by
  g.feat_id;

analyse tmp_feat_point;

-- Create arbitrary reference points for features with no geometry

create temp table tmp_no_geom
as 
select 
   d.feat_id,
   min(d.src) as src
from
   data d
   left outer join tmp_feat_point fp on fp.feat_id=d.feat_id
where
   fp.feat_id IS NULL
group by
   d.feat_id;
   
insert into tmp_feat_point( feat_id, geom, isreal )
select 
   feat_id,
   CASE WHEN src like 'AN%' 
   THEN st_SetSRID(st_Point(175,-70),4167) 
   ELSE st_SetSRID(st_Point(170,-40),4167) 
   END,
   FALSE
FROM
   tmp_no_geom;

drop table tmp_no_geom;

analyse tmp_feat_geom;

analyse tmp_feat_point;


