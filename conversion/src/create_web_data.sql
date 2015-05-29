-- Script to generate a web data set for web database.  This is temporary
-- version, based on the import tables rather than on the real data.  Mainly
-- doing stuff to try and get the spatial layers about right...

set search_path=gazetteer_web, gazetteer, gazetteer_import, public;
set search_path=gazetteer_web, gazetteer, gazetteer_import, public;
SET client_min_messages=WARNING;

truncate gaz_feature;
truncate gaz_name;
truncate gaz_word;
truncate gaz_shape;
truncate gaz_annotation;

-- ----------------------------------------------------------------------------
-- Populate gaz_code

truncate gaz_code;

insert into gaz_code (code_group, code, value)
select code_group, code, value from system_code where code_group in ('FTYP','FSTS','NSTS','NEVT','AUTH');

insert into gaz_code (code_group, code, value)
select code_group, code, value from system_code where code='CODE' and code in ('FTYP','FSTS','NSTS','NEVT','AUTH');

insert into gaz_code (code_group, code, value )
values ('CODE','ARFT','Annotation reference type');
insert into gaz_code (code_group, code, value )
values ('ARFT','FEAT','Feature annotation');
insert into gaz_code (code_group, code, value )
values ('ARFT','NAME','Name annotation');

-- Far from final list ... this is for testing only at present
insert into gaz_code (code_group, code, value )
values ('CODE','ANTP','Annotation type');
insert into gaz_code (code_group, code, value )
values ('ANTP','DESC','Description');
insert into gaz_code (code_group, code, value )
values ('ANTP','DSTC','District');
insert into gaz_code (code_group, code, value )
values ('ANTP','KMLR','Location');
insert into gaz_code (code_group, code, value )
values ('ANTP','LOCN','Location');
insert into gaz_code (code_group, code, value )
values ('ANTP','ORGN','Origin');

-- Name priority group

insert into gaz_code( code_group, code, value )
values ('CODE','NSTP','Name status priority');

insert into gaz_code( code_group, code, value )
select
   'NSTP',
    code,
    (CASE WHEN value LIKE 'Official%' OR value LIKE 'Statutory%' THEN 'O' ELSE 'U' END) ||
    (lpad((row_number() OVER (ORDER BY value))::varchar,3,'0'))
FROM
    gaz_code
WHERE
    code_group='NSTS' ;


-- ----------------------------------------------------------------------------
-- Populate gaz_feature

truncate gaz_feature;

insert into gaz_feature( id, type, status, description )
select 
   fd.feat_id,
   max(ft.ftype_code), -- NOTE: THIS NEEDS TO BE ADDRESSED!!!
   'CURR',
   fd.description
from
   tmp_feat_desc fd 
   join tmp_feat_type ft on ft.feat_id = fd.feat_id
where
   fd.feat_id in (select feat_id from tmp_feat_gis)
group by
   fd.feat_id,
   fd.description
   ;


-- ----------------------------------------------------------------------------
-- Populate gaz_name

truncate gaz_name;

insert into gaz_name( 
   id, 
   feat_id,
   ascii_name,
   name,
   status
   )
select
   id, 
   feat_id,
   gaz_plaintext(name),
   name,
   status
from
   tmp_name
where
   feat_id in (select id from gaz_feature);


-- ----------------------------------------------------------------------------
-- Populate gaz_shape

-- At the moment many of these objects are too complex to use in a vector web service ... up to 22,000 points :-(
-- Maximum for a single feature is 6185

-- select sum(st_npoints(shape)) from gaz_shape where max_zoom=100 group by feat_id order by sum(st_npoints(shape)) desc
-- select max(st_npoints(shape)) from gaz_shape;
-- select min(min_zoom) from gaz_shape group by feat_id order by min(min_zoom) desc;

-- At the moment many of these objects are too complex to use in a vector web service ... up to 22,000 points :-(
-- Maximum for a single feature is 6185

-- select sum(st_npoints(shape)) from gaz_shape where max_zoom=100 group by feat_id order by sum(st_npoints(shape)) desc
-- select max(st_npoints(shape)) from gaz_shape;
-- select min(min_zoom) from gaz_shape group by feat_id order by min(min_zoom) desc;

truncate gaz_shape;

drop table if exists tmp_gis2;

create temp table tmp_gis2
(
id int not null,
gsrc char(1) not null,
feat_id int not null,
geom geometry not null,
primary key (id, gsrc)
);

insert into tmp_gis2 (id, gsrc, feat_id, geom )
select
   id, 
   gsrc,
   feat_id,
   st_transform( st_setsrid(geom, srid), 4167 )
from 
   tmp_feat_gis
where
   feat_id in (select id from gaz_feature)
   ; 
   
create index tmp_fid on tmp_gis2( feat_id );

drop table if exists tmp_gis3;
create temp table tmp_gis3
(
   feat_id int not null primary key,
   geom geometry
);

insert into tmp_gis3( feat_id, geom )
select
  feat_id,
  st_setsrid( st_extent(geom), 4167)
from
  tmp_gis2
group by
  feat_id;

-- For now base the zoom levels on the number of features of the type.
-- This will need to be refined significantly, to start with by better 
-- categorisation.  Then perhaps by looking at size of features, where not
-- just points ...
--
-- http://gis.stackexchange.com/questions/7430/google-maps-zoom-level-ratio
-- Google's web map tile has 256 pixels of width
-- let's say your computer monitor has 100 pixels per inch (PPI). That means 256 pixels are roughly 6.5 cm of length. And that's 0.065 m.
-- 
-- on zoom level 0, the whole 360 degrees of longitude are visible in a single tile. You cannot observe this in Google Maps since it automatically moves to the zoom level 1, but you can see it on OpenStreetMap's map (it uses the same tiling scheme).
-- 
-- 360 degress on the Equator are equal to Earth's circumference, 40,075.16 km, which is 40075160 m
-- 
-- divide 40075160 m with 0.065 m and you'll get 616313361, which is a scale of zoom level 0 on the Equator for a computer monitor with 100 DPI
-- 
-- so the point is that the scale depends on your monitor's PPI and on the latitude (because of the Mercator projection)
-- for zoom level 1, the scale is one half of that of zoom level 0
-- ...
-- for zoom level N, the scale is one half of that of zoom level N-1
--
-- We want maximum of 200 features of a type to be displayed...
-- NZ extents are approx 10x10 degrees, of which say 20% is land, so 200 degrees squared.
-- So if M points, average density is approx M/200 points per degrees squared.
-- Zoom level 0 displays 360*360 degrees squared.  
-- So zoom level n displays approx 360*360/(4**n) degrees squared.
-- So number of points at zoom level n is 360*360*M/(200*(4**n))
-- So choose n such that 360*360*M/(200*(4**n)) < 200.
-- For safety (ie as we know points will be clustered), reduce to < 100.
-- So require 4**n > (360*360*M/200*100)
-- Or   n > log(360*360*M/(200*100))/log(4)
-- ie n > ln(M)/ln(4)+ln(6.48)/ln(4)
--    n > ln(M)/1.4862 + 1,35
--    nmin = ceiling(ln(M)/1.4862 + 1.35)
--  Don't show any features until zoomed into country scale, ie zoom level about 5
--
-- Revised to only show about 20 features, as at the moment have too many feature classes, ie add ln(10)=2.3

drop table if exists tmp_ftype_min_scale;

create temp table tmp_ftype_scale (
    type char(4) not null primary key,
    min_scale int
    );

insert into tmp_ftype_scale( type, min_scale )
select 
    type,
    greatest(5,ceiling(ln(count(*))/1.486+1.35+2.3))
from
    gaz_feature
group by type;

-- Insert point references to each entity into the shape table.

insert into gaz_shape( feat_id, min_zoom, max_zoom, shape )
select
   f.id,
   s.min_scale,
   100,
   st_centroid(g.geom)
from
   gaz_feature f
   join tmp_gis3 g on g.feat_id = f.id
   join tmp_ftype_scale s on s.type=f.type;
   
drop table if exists tmp_ftype_scale;

-- Now work out a min scale for the full extents of the geometry.  Slightly crude
-- approach as follows:
--  1) Work out maximum extent in degrees, based RMS of y range and x range / cos(mid y range)
--  2) Convert to pixels - At zoom 0, 360 degrees = 256 pixels, at zoom n 360/2**n degrees = 256 pixels,
--     so pixels per degree is 256/(360/2**n), So the number of pixels to display the object is 
--       range * 256 * 2**n / 360.
--  3) Want this to be at least 10 pixels to display, so require
--       range * 256 * 2**n / 360 > 10,
--      ie  2**n > 3600/(256*range)
--             n > ln(3600/(256*range))/ln(2)
--             n > (2.64-ln(range))/0.6931
--             nmin = ceiling((2.64-ln(range))/0.6931)

-- Select the set of features with complex geometries (assume these are only defined in data from ArcGIS for the moment
-- (some of the hydro features in spreadsheet data have multiple point geometries - to be handled later).  Complex 
-- geometries are those with non-point format or more than one feature.

drop table if exists tmp_gis4;
create temp table tmp_gis4
(
    feat_id integer not null primary key,
    extents geometry not null,
    min_scale int
);

insert into tmp_gis4( feat_id, extents )
select
   feat_id,
   ST_Extent(geom)
from 
   tmp_gis2
where
   gsrc = 'A' and
   (GeometryType(geom) <> 'POINT' or
   feat_id not in
   (
	select 
	   feat_id
	from 
	   tmp_feat_gis
	where
	   gsrc='A'
	group by
	   feat_id
	having
	   count(*) = 1
    ))
group by
    feat_id;

update
    tmp_gis4
set
    min_scale = greatest(5,ceiling((2.64-ln(sqrt(st_area(extents))/cos(radians(st_y(st_centroid(extents))))))/0.6931));

-- Reset the maximum scale for point representation of features that have an alternative shape representation

update gaz_shape
set
   max_zoom = (select min_scale-1 from tmp_gis4 where feat_id=gaz_shape.feat_id)
where
   feat_id in (select feat_id from tmp_gis4);

delete from gaz_shape 
where min_zoom > max_zoom;

-- Add the complex features...

insert into gaz_shape( feat_id, min_zoom, max_zoom, shape )
select
   g.feat_id,
   s.min_scale,
   100,
   g.geom
from
   tmp_gis2 g
   join tmp_gis4 s on s.feat_id = g.feat_id;

-- At the moment many of these objects are too complex to use in a vector web service ... up to 22,000 points :-(
-- Maximum for a single feature is 6185

--  Set up table to simplify features according to scale...
--  As per previous example, degrees per pixel is about 360/256*(2**n)
--  So for zoom level n, simplify to half this, ie tunnel half width = 90/256*(2**n) = 0.35/2**n.
--
-- In practice this appears too fine, so reduce to 1.5/2**n to start with...

CREATE OR REPLACE FUNCTION create_simpler_shapes( zmin INT, zmax INT )
RETURNS INT
AS
$code$
DECLARE
   thw FLOAT;
BEGIN
    -- Work out the tunnel half width for scaling
    -- Final range (ie to infinity = 100) simplifies to top of the range
    IF zmax = 100 THEN 
	thw := 1.5/(2.0^zmin); 
    ELSE
        thw := 1.5/(2.0^zmax);
    END IF;
    -- Create a temp table for holding the simplified geometries
    DROP TABLE IF EXISTS tmp_simplified_geom;
    DROP TABLE IF EXISTS tmp_simplified_geom_id;
    CREATE TEMP TABLE tmp_simplified_geom_id( id INT primary key );
    CREATE TEMP TABLE tmp_simplified_geom( feat_id INT primary key, min_zoom INT, max_zoom INT, shape GEOMETRY );
    -- Load the simplified geometries with a zoom level overlapping the range of interest
    -- Only interested in non-point geometries (cannot simplify points!)
    INSERT INTO tmp_simplified_geom_id
    SELECT id
    FROM gaz_shape
    WHERE GeometryType(shape) <> 'POINT' AND
          min_zoom <= zmax AND max_zoom >= zmin;

    INSERT INTO tmp_simplified_geom
    SELECT feat_id, min(min_zoom), max(max_zoom),St_SimplifyPreserveTopology( st_union( st_buffer(shape, thw*0.5, 1 )), thw )
    FROM gaz_shape
    WHERE id IN (SELECT id FROM tmp_simplified_geom_id)
    GROUP BY feat_id;

    -- For shapes with a max_zoom in the range of interest, just remove the existing the geometry
    DELETE FROM gaz_shape
    WHERE id IN (SELECT id FROM tmp_simplified_geom_id) AND max_zoom <= zmax;

    -- For the remaining shapes, update the min_zoom level for the current version to be zmax+1,
    -- Update the max zoom in the tmp table to be zmax, and append the new shapes to the tmp table.
    UPDATE gaz_shape SET min_zoom=zmax+1 WHERE id IN (SELECT id FROM tmp_simplified_geom_id);

    INSERT INTO gaz_shape (feat_id, min_zoom, max_zoom, shape )
    SELECT feat_id, min_zoom, zmax, shape FROM tmp_simplified_geom;
         
    -- DROP TABLE IF EXISTS tmp_simplified_geom;
    -- DROP TABLE IF EXISTS tmp_simplified_geom_id;
    RETURN 1;
END
$code$
LANGUAGE plpgsql;

SELECT create_simpler_shapes( 15, 100 );
SELECT create_simpler_shapes( 12,14 );
SELECT create_simpler_shapes( 9,11 );
SELECT create_simpler_shapes( 6, 8 );

-- Replace multi... with individual geometries (better indexing etc).

DROP TABLE IF EXISTS tmp_simple_geoms;
CREATE TEMP TABLE tmp_simple_geoms AS
SELECT feat_id, min_zoom, max_zoom, ST_GeometryN(shape, generate_series(1, ST_NumGeometries(shape))) as shape 
FROM gaz_shape WHERE GeometryType(shape) IN ('MULTIPOLYGON','MULTILINESTRING');

DELETE FROM gaz_shape WHERE GeometryType(shape) IN ('MULTIPOLYGON','MULTILINESTRING');
INSERT INTO gaz_shape (feat_id, min_zoom, max_zoom, shape)
SELECT feat_id, min_zoom, max_zoom, shape 
FROM tmp_simple_geoms;

DROP TABLE tmp_simple_geoms;

-- -- Reduce number of decimal places...
-- 
-- DROP TABLE IF EXISTS tmp_ndp_re;
-- CREATE TEMP TABLE tmp_ndp_re AS
-- SELECT generate_series(1,15) as zoom,''::varchar(50) as re;
-- 
-- UPDATE tmp_ndp_re
-- SET re=E'(\\.\\d{' || greatest(ceiling(-log(0.15/(2.0^zoom))),1)::varchar || E'})\\d*';
-- 
-- UPDATE gaz_shape
-- SET shape=ST_GeomFromText(regexp_replace(ST_AsText(shape),
--     (SELECT re FROM tmp_ndp_re WHERE zoom=least(15,gaz_shape.max_zoom)),E'\\1','g'),
--     ST_Srid(shape));

-- select sum(st_npoints(shape)) from gaz_shape where max_zoom=100 group by feat_id order by sum(st_npoints(shape)) desc
-- select max(st_npoints(shape)) from gaz_shape;
-- select min(min_zoom) from gaz_shape group by feat_id order by min(min_zoom) desc;

-- Add annotations from the source data
-- Just test values at the moment

-- --------------------------------------------------------------------------------------------
-- Populate gaz_annotation

truncate gaz_annotation;

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, is_html, note_type, note )
select 
   'FEAT',
   fd.feat_id,
   0,
   'N',
   'Y',
   'N',
   'DESC',
   fd.description
from
   tmp_feat_desc fd 
where
   feat_id in (select feat_id from gaz_name);

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   1,
   'N',
   'Y',
   'N',
   'ORGN',
   d.info_origin
from
   gaz_name n
   join data d on d.id = n.id
where
   d.info_origin is not null;

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   2,
   'N',
   'Y',
   'N',
   'DSTC',
   d.district
from
   gaz_name n
   join data d on d.id = n.id
where
   d.district is not null;

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, is_html, note_type, note )
select
   'FEAT',
   n.id,
   3,
   'Y',
   'N',
   'N',
   'KMLR',
   'Antarctica'
from 
   gaz_name n
   join data d on d.id = n.id
where
   d.src in ('ANON','ANCN','ANXN');

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, is_html, note_type, note )
select
   'FEAT',
   n.id,
   4,
   'Y',
   'Y',
   'Y',
   'LOCN',
   'Not displayed on map, view <a href="http://www.linz.govt.nz">here</a>'
from 
   gaz_name n
   join data d on d.id = n.id
where
   d.src in ('ANON','ANCN','ANXN');

-- Create a table of words for search index (plain_texted, lower case)
-- --------------------------------------------------------------------------------------------
-- Populate gaz_word

truncate gaz_word;

insert into gaz_word( name_id, nword, word )
with w(id,words) as (
select 
     id, 
     gaz_plaintextwords(name)
from gaz_name
),
nw( id, n ) as (
select 
   id,
   generate_series(1,array_length(words,1))
from
   w
   )
select
   w.id as name_id,
   nw.n as nword,
   words[n] as word
from 
   w join nw on w.id = nw.id;

analyze gaz_feature;
analyze gaz_name;
analyze gaz_word;
analyze gaz_shape;
analyze gaz_annotation;
analyze gaz_code;

-- copy tmp_gaz_words to 'c:/<path>/temp/gaz_web/gaz_name_words.csv' with csv header;
-- copy gaz_feature to 'c:/<path>/temp/gaz_web/gaz_feature.csv' with csv header;
-- copy gaz_name to 'c:/<path>/temp/gaz_web/gaz_name.csv' with csv header;
-- copy (select * from gaz_shape where GeometryType(shape) = 'POINT') to 'c:/<path>/temp/gaz_web/gaz_shape_point.csv' with csv header;
-- copy (select * from gaz_shape where GeometryType(shape) = 'LINESTRING') to 'c:/<path>/temp/gaz_web/gaz_shape_line.csv' with csv header;
-- copy (select * from gaz_shape where GeometryType(shape) = 'POLYGON') to 'c:/<path>/temp/gaz_web/gaz_shape_poly.csv' with csv header;
-- copy tmp_gaz_words to 'c:/<path>/temp/gaz_web/gaz_name_words.csv' with csv header;
-- copy gaz_annotation to 'c:/<path>/temp/gaz_web/gaz_annotation.csv' with csv header;
-- cop gaz_code to 'c:/<path>/temp/gaz_web/gaz_code.csv' with csv header;
