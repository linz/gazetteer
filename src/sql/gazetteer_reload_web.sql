-- ###############################################################################
-- 
--  Copyright 2015 Crown copyright (c)
--  Land Information New Zealand and the New Zealand Government.
--  All rights reserved
-- 
--  This program is released under the terms of the new BSD license. See the 
--  LICENSE file for more information.
-- 
-- ###############################################################################

-- Script to generate a web data set for web database.  This is temporary
-- version, based on the import tables rather than on the real data.  Mainly
-- doing stuff to try and get the spatial layers about right...

set search_path=gazetteer_web, gazetteer, public;
set search_path=gazetteer_web, gazetteer, public;
SET client_min_messages=WARNING;

-- HTML encode a string

CREATE OR REPLACE FUNCTION gazetteer.gweb_html_encode( string TEXT )
RETURNS TEXT
AS
$body$
    SELECT 
       replace(
       replace(
       replace(
       replace(
            $1,
            '&','&amp;'),
            '"','&quot;'),
            '<','&lt;'),
            '>','&gt;')
$body$
LANGUAGE sql IMMUTABLE;

-- ----------------------------------------------------------------------------
-- Populate gaz_event

CREATE OR REPLACE FUNCTION gazetteer.gweb_update_gaz_event()
RETURNS INTEGER
AS
$code$
truncate gaz_event;

insert into gaz_event (event_id, name_id, event_date, event_type, event_reference)
select event_id, name_id, event_date, event_type, gaz_plaintext(event_reference) from  name_event;

ANALYZE gaz_event;

SELECT 1;

$code$
LANGUAGE sql
SET search_path FROM CURRENT;

-- ----------------------------------------------------------------------------
-- Populate gaz_code

CREATE OR REPLACE FUNCTION gazetteer.gweb_update_gaz_code()
RETURNS INTEGER
AS
$code$
truncate gaz_code;

-- Added FCLS to code group types for updated web app
insert into gaz_code (code_group, code, category, value)
select code_group, code, category, value from system_code where code_group in ('FTYP','FSTS','NSTS','NEVT','AUTH','FCLS');

insert into gaz_code (code_group, code, category, value)
select code_group, code, category, value from system_code where code='CODE' and code in ('FTYP','FSTS','NSTS','NEVT','AUTH');

insert into gaz_code (code_group, code, value )
values ('CODE','ARFT','Annotation reference type');
insert into gaz_code (code_group, code, value )
values ('ARFT','FEAT','Feature annotation');
insert into gaz_code (code_group, code, value )
values ('ARFT','NAME','Name annotation');

insert into gaz_code (code_group, code, value )
values ('CODE','ANTP','Annotation type');
insert into gaz_code (code_group, code, value )
values ('ANTP','DESC','Description');
insert into gaz_code (code_group, code, value )
values ('ANTP','DSTC','District');
insert into gaz_code (code_group, code, value )
values ('ANTP','LOCN','Location');
insert into gaz_code (code_group, code, value )
values ('ANTP','OFFS','Official name status');

insert into gaz_code (code_group, code, value )
values ('ANTP','ORGN','Origin');

-- Name priority group

insert into gaz_code( code_group, code, value )
values ('CODE','NSTP','Name status priority');

insert into gaz_code( code_group, code, value )
select
   'NSTP',
    sc.code,
    (CASE WHEN sc.category = 'OFFC' THEN 'O' ELSE 'U' END) ||
    (lpad((row_number() OVER (ORDER BY COALESCE(sco.value,'zzzz'),sc.value))::varchar,3,'0'))
FROM
    system_code sc
    left outer join system_code sco ON sco.code_group='NSTO' AND sco.code=sc.code
WHERE
    sc.code_group='NSTS' ;

ANALYZE gaz_code;

SELECT 1;

$code$
LANGUAGE sql
SET search_path FROM CURRENT;

-- ----------------------------------------------------------------------------
-- Populate gaz_feature

CREATE OR REPLACE FUNCTION gazetteer.gweb_update_gaz_feature()
RETURNS INTEGER
AS
$code$
BEGIN

DROP TABLE IF EXISTS tmp_name_id;

CREATE TEMP TABLE tmp_name_id AS
SELECT 
   n.name_id,
   n.feat_id
FROM 
   name n
   join feature f on f.feat_id = n.feat_id
   join system_code ftsc on ftsc.code_group='FTYP' and ftsc.code=f.feat_type
   left outer join system_code sc ON sc.code_group='NSTS' and sc.code=n.status and sc.category='NPUB'
   left outer join name_annotation na ON na.name_id=n.name_id AND na.annotation_type='NPUB'
   left outer join feature_annotation fa ON fa.feat_id=n.feat_id AND fa.annotation_type='NPUB'
WHERE
   f.feat_type NOT IN (SELECT code FROM system_code WHERE code_group='XNPF') AND
   sc.code IS NULL AND
   na.name_id IS NULL AND
   fa.feat_id IS NULL AND
   f.status='CURR';

CREATE INDEX tmp_name_id_fid ON tmp_name_id( feat_id );
CREATE INDEX tmp_name_id_nid ON tmp_name_id( name_id );
ANALYZE tmp_name_id;

truncate gaz_feature;

insert into gaz_feature( id, type, status, description )
select 
   f.feat_id,
   f.feat_type,
   f.status,
   f.description
from
   feature f
WHERE
   f.feat_id IN (select feat_id from tmp_name_id);

ANALYZE gaz_feature;
RETURN 1;
END
$code$

LANGUAGE plpgsql
SET search_path FROM CURRENT;

-- select gweb_update_gaz_feature()

-- ----------------------------------------------------------------------------
-- Populate gaz_name, gaz_word

CREATE OR REPLACE FUNCTION gazetteer.gweb_update_gaz_name()
RETURNS INTEGER
AS
$code$
BEGIN
truncate gaz_name;

insert into gaz_name( 
   id, 
   feat_id,
   ascii_name,
   name,
   status
   )
select
   n.name_id, 
   n.feat_id,
   gaz_plaintext(n.name),
   n.name,
   n.status
from
   name n
   JOIN tmp_name_id tid ON tid.name_id = n.name_id;

ANALYZE gaz_name;

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

ANALYZE gaz_word;

RETURN 1;
END
$code$
LANGUAGE plpgsql
SET search_path FROM CURRENT;

-- select gweb_update_gaz_name();

-- --------------------------------------------------------------------------------------------
-- Populate gaz_annotation

CREATE OR REPLACE FUNCTION gazetteer.gweb_update_gaz_annotation()
RETURNS INTEGER
AS
$code$
BEGIN

truncate gaz_annotation;

-- Feature annotations - description


insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'FEAT',
   f.feat_id,
   1,
   'N',
   'Y',
   'Y',
   'Y',
   'DESC',
   '<p class="hanging_indent"><span class="annot_prefix">Feature Type:</span> ' || gweb_html_encode(s.value) || '</p>'
from
   feature f 
   join system_code s ON s.code_group='FTYP' and s.code=f.feat_type
where
   f.feat_id in (select feat_id from gaz_feature);

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'FEAT',
   feat_id,
   2,
   'N',
   'Y',
   'Y',
   'Y',
   'DESC',
   '<p class="hanging_indent">' || gweb_html_encode(description) || '</p>'
from
   feature 
where
   feat_id in (select feat_id from gaz_feature);

-- Name annotation - is official or not.

DROP TABLE IF EXISTS tmp_gweb_name_is_official;
CREATE TEMP TABLE tmp_gweb_name_is_official AS
SELECT
   id AS name_id,
   feat_id
FROM
   gaz_name
WHERE status IN (select CODE from gaz_code where code_group='NSTP' and value like 'O%')
  ;
CREATE INDEX  idx_tmp_gweb_name_is_official_name_id ON tmp_gweb_name_is_official(name_id); 
CREATE INDEX  idx_tmp_gweb_name_is_official_feat_id ON tmp_gweb_name_is_official(feat_id); 
ANALYZE tmp_gweb_name_is_official;

drop table if exists tmp_name_last_event;
create temp table tmp_name_last_event as
select
   name_id,
   event_type,
   event_reference, 
   row_number() over (partition by name_id order by event_date desc) as rowno
from 
   name_event;

delete from tmp_name_last_event where rowno <> 1 or event_type not in ('NZGZ','TSLG','DOCG');

create index tmp_name_last_event_id on tmp_name_last_event( name_id );
analyze tmp_name_last_event;

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   id,
   10,
   'N',
   'Y',
   'Y',
   'Y',
   'OFFS',
   '<p class="hanging_indent">' ||
   (CASE
      WHEN id IN (SELECT name_id FROM tmp_gweb_name_is_official) THEN 'This is an official name'
      WHEN feat_id IN (SELECT feat_id FROM tmp_gweb_name_is_official) THEN 'This is not an official name'
      ELSE 'This name is not official - this feature does not have an official name'
      END) ||
   '</p>'
from
   gaz_name n;

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   id,
   15,
   'N',
   'Y',
   'Y',
   'Y',
   'OFFS',
   '<p class="hanging_indent"><span class="annot_prefix">Status:</span> ' || gweb_html_encode(gc.value) ||
   CASE WHEN ne.event_type IS NULL THEN '' ELSE ' (' || gweb_html_encode(ne.event_reference) || ')' END || '</p>'
from
   gaz_name n
   join name nm ON nm.name_id = n.id
   join gaz_code gc ON gc.code_group='NSTS' and gc.code=nm.status
   left outer join tmp_name_last_event ne on ne.name_id = n.id;

   
DROP TABLE IF EXISTS tmp_name_last_event;
DROP TABLE IF EXISTS tmp_gweb_name_is_official;

-- Name annotation history/origin/meaning, notes

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   20,
   'N',
   'Y',
   'Y',
   'Y',
   'ORGN',
   '<p class="hanging_indent"><span class="annot_prefix">History/Origin/Meaning:</span> ' || gweb_html_encode(d.annotation) || '</p>'
from
   gaz_name n
   join name_annotation d on d.name_id = n.id and d.annotation_type='HORM';

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   22,
   'N',
   'N',
   'Y',
   'Y',
   'ORGN',
   '<p class="hanging_indent"><span class="annot_prefix">Reference Information:</span> ' || gweb_html_encode(d.annotation) || '</p>'
from
   gaz_name n
   join name_annotation d on d.name_id = n.id and d.annotation_type='FLRF';


insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   24,
   'N',
   'N',
   'Y',
   'Y',
   'ORGN',
   '<p class="hanging_indent"><span class="annot_prefix">Other Notes:</span> ' || gweb_html_encode(d.annotation) || '</p>'
from
   gaz_name n
   join name_annotation d on d.name_id = n.id and d.annotation_type='NNOT';

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   26,
   'N',
   'N',
   'Y',
   'Y',
   'ORGN',
   '<p class="hanging_indent"><span class="annot_prefix">Māori Name:</span> ' ||
   (CASE 
      WHEN d.annotation ilike 'yes' THEN 'Yes'
      WHEN d.annotation ilike 'no' THEN 'No'
      WHEN d.annotation ilike 'tbi' THEN 'To be investigated'
      ELSE 'Unknown'
      END) || '</p>'
from
   gaz_name n
   join name_annotation d on d.name_id = n.id and d.annotation_type='MRIN';

-- Land district

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   30,
   'N',
   'N',
   'Y',
   'Y',
   'LOCN',
   '<p class="hanging_indent"><span class="annot_prefix">Land District:</span> ' || gweb_html_encode(d.annotation) || '</p>'
from
   gaz_name n
   join feature_annotation d on d.feat_id = n.feat_id and d.annotation_type='LDIS';

-- Doc conservancy

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   32,
   'N',
   'N',
   'Y',
   'Y',
   'LOCN',
   '<p class="hanging_indent"><span class="annot_prefix">DOC Conservancy:</span> ' || gweb_html_encode(d.annotation) || '</p>'
from
   gaz_name n
   join name_annotation d on d.name_id = n.id and d.annotation_type='DOCC';

-- Island

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   34,
   'N',
   'N',
   'Y',
   'Y',
   'LOCN',
   '<p class="hanging_indent">This feature is on ' ||
   CASE WHEN d.annotation ~* 'islands$' THEN 'the ' ELSE '' END ||
   gweb_html_encode(d.annotation) || '</p>'
from
   gaz_name n
   join feature_annotation d on d.feat_id = n.feat_id and d.annotation_type='ISLD'
where
   d.annotation !~* E'\\s*(north|south)\\s+island\\s*$';

-- Undersea/antarctic

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   36,
   'N',
   'N',
   'Y',
   'Y',
   'LOCN',
   '<p class="hanging_indent">This is an undersea feature.</p>'
from
   gaz_name n
   join feature f on f.feat_id = n.feat_id 
   join system_code s on s.code_group='FTYP' and s.code=f.feat_type
where
   s.category='USEA';

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'NAME',
   n.id,
   38,
   'N',
   'N',
   'Y',
   'Y',
   'LOCN',
   '<p class="hanging_indent">This feature is in Antarctica.</p>'
from
   gaz_name n
   join feature f on f.feat_id = n.feat_id 
   join system_code s on s.code_group='FTYP' and s.code=f.feat_type
where
   ST_Y(f.ref_point) < -60.0 AND
   s.category <> 'USEA';


-- 
-- insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
-- select
--    'FEAT',
--    n.id,
--    30,
--    'Y',
--    'Y',
--    'Y',
--    'N',
--    'LOCN',
--    'Location: Antarctica'
-- from 
--    gaz_name n
--    join data d on d.id = n.id
-- where
--    d.src in ('ANON','ANCN','ANXN');

drop table if exists tmp_name_latlon;

CREATE TEMP TABLE tmp_name_latlon AS
SELECT
   f.feat_id,
   ROUND(ST_Y(f.ref_point)::numeric,6) AS lat,
   ROUND((CASE WHEN ST_X(f.ref_point) > 180 THEN ST_X(f.ref_point)-360 ELSE ST_X(f.ref_point) END)::numeric,6)  AS lon
FROM
   feature f
WHERE 
   feat_id in (select feat_id from gaz_name);   


insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select
   'FEAT',
   feat_id,
   40,
   'N',
   'Y',
   'Y',
   'Y',
   'LOCN',
   '<p class="hanging_indent"><span class="annot_prefix">Approximate Location:</span> '
   ||
   CASE WHEN lat >= 0 THEN
      ROUND(lat,3)::varchar || 'N' 
   ELSE
      ROUND(-lat,3)::varchar || 'S'
   END
   || ' ' ||
   CASE WHEN lon >= 0 THEN
      ROUND(lon,3)::varchar || 'E' 
   ELSE
      ROUND(-lon,3)::varchar || 'W'
   END
   ||
   ' (View in <a target="_blank" href="http://maps.google.co.nz/maps?q=loc:' ||
     lat::varchar || ',' || lon::varchar ||
     '&z=5&t=m">Google maps</a>)</p>'
from 
   tmp_name_latlon;


insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select 
   'FEAT',
   d.feat_id,
   42,
   'N',
   'Y',
   'Y',
   'Y',
   'ORGN',
   '<p class="hanging_indent"><span class="annot_prefix">Feature Notes:</span> ' || gweb_html_encode(d.annotation) || '</p>'
from
   feature_annotation d 
where
   d.annotation_type='FNOT' and
   d.feat_id in (select feat_id from gaz_name);

insert into gaz_annotation( ref_type, ref_id, sequence, list_view, details_view, selected_detail_view, is_html, note_type, note )
select
   'NAME',
   n.id,
   40,
   'Y',
   'N',
   'N',
   'Y',
   'LOCN',
   '<p class="hanging_indent">View location in <a target="_blank" href="http://maps.google.co.nz/maps?q=loc:' ||
     ll.lat::varchar || ',' || ll.lon::varchar ||
     '&z=5&t=m">Google maps</a>)</p>'
from
   gaz_name n  
   join tmp_name_latlon ll on n.feat_id = ll.feat_id;

DROP TABLE tmp_name_latlon;

-- Tried to include name as annotation in google maps but didn't work :-(

analyze gaz_annotation;

RETURN 1;
END

$code$
LANGUAGE plpgsql
SET search_path FROM CURRENT;

-- SELECT gweb_update_gaz_annotation()


-- At the moment many of these objects are too complex to use in a vector web service ... up to 22,000 points :-(
-- Maximum for a single feature is 6185

--  Set up table to simplify features according to scale...
--  As per previous example, degrees per pixel is about 360/256*(2**n)
--  So for zoom level n, simplify to half this, ie tunnel half width = 90/256*(2**n) = 0.35/2**n.
--
-- In practice this appears too fine, so reduce to 1.5/2**n to start with...

CREATE OR REPLACE FUNCTION gazetteer.gweb_simplify_shapes( zmin INT, zmax INT )
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
LANGUAGE plpgsql
SET search_path FROM CURRENT;

-- ----------------------------------------------------------------------------
-- Populate gaz_shape

-- At the moment many of these objects are too complex to use in a vector web service ... up to 22,000 points :-(
-- Maximum for a single feature is 6185

-- select sum(st_npoints(shape)) from gaz_shape where max_zoom=100 group by feat_id order by sum(st_npoints(shape)) desc
-- select max(st_npoints(shape)) from gaz_shape;
-- select min(min_zoom) from gaz_shape group by feat_id order by min(min_zoom) desc;

-- select min(min_zoom) from gaz_shape group by feat_id order by min(min_zoom) desc;

CREATE OR REPLACE function gazetteer.gweb_update_gaz_shape()
RETURNS INT
AS
$body$
BEGIN

truncate gaz_shape;

drop table if exists tmp_gis2;

create temp table tmp_gis2
(
feat_id int not null,
geom geometry not null
);

-- Only want polygons for some feature types at present..

insert into tmp_gis2 (feat_id, geom )
select
   g.feat_id,
   g.shape
from 
   feature_geometry g
   join feature f on g.feat_id = f.feat_id
where
   g.feat_id in (select id from gaz_feature)
   and (
    g.geom_type <> 'P' or 
    f.feat_type in (
        'LAKE',
        'STRM'
    ))
   ; 
   
create index tmp_fid on tmp_gis2( feat_id );
analyze tmp_gis2;

insert into tmp_gis2 (feat_id, geom )
select
   f.feat_id,
   f.ref_point
from 
   feature f
   join gaz_feature gf on gf.id = f.feat_id
   left outer join tmp_gis2 g on g.feat_id = f.feat_id
where
   g.feat_id is NULL
   ; 
   
analyze tmp_gis2;

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

-- THE FOLLOWING CODE WAS USED FOR THE INITIAL CONVERSION AND IS NOW NOT USED
--
-- When the plan was to display a base layer of gazetteer features this was required
-- to determine which features to display at a given zoom level
--
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
-- 
-- drop table if exists tmp_ftype_min_scale;
-- 
-- create temp table tmp_ftype_scale (
--     type char(4) not null primary key,
--     min_scale int
--     );
-- 
-- insert into tmp_ftype_scale( type, min_scale )
-- select 
--     type,
--     greatest(5,ceiling(ln(count(*))/1.486+1.35+2.3))
-- from
--     gaz_feature
-- group by type;
-- Insert point references to each entity into the shape table.
-- 
-- insert into gaz_shape( feat_id, min_zoom, max_zoom, shape )
-- select
--    f.id,
--    s.min_scale,
--    100,
--    st_centroid(g.geom)
-- from
--    gaz_feature f
--    join tmp_gis3 g on g.feat_id = f.id
--    join tmp_ftype_scale s on s.type=f.type;
--    
-- drop table if exists tmp_ftype_scale;

insert into gaz_shape( feat_id, min_zoom, max_zoom, shape )
select
   f.id,
   0,
   100,
   sf.ref_point
from
   gaz_feature f
   join feature sf on sf.feat_id = f.id;

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
   (GeometryType(geom) <> 'POINT' or
   feat_id in
   (
	select 
	   feat_id
	from 
           tmp_gis2
	group by
	   feat_id
	having
	   count(*) > 1
    ))
group by
    feat_id;

update
    tmp_gis4
set
    min_scale = greatest(5,ceiling((2.64-ln(greatest(sqrt(st_area(extents))/cos(radians(st_y(st_centroid(extents)))),0.00000001)))/0.6931));

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
-- Remove current map zoom levels are only from 5 to 14
-- PERFORM gweb_simplify_shapes( 15, 100 );
-- PERFORM gweb_simplify_shapes( 12,14 );
PERFORM gweb_simplify_shapes( 12,100 );
PERFORM gweb_simplify_shapes( 9,11 );
PERFORM gweb_simplify_shapes( 6, 8 );

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

-- Remove redundant zoom levels.
DELETE FROM gaz_shape WHERE max_zoom < 5;
UPDATE gaz_shape SET min_zoom=0 WHERE min_zoom <= 5;

ANALYZE gaz_shape;

-- Set the extents of features in gaz_name to support spatially filtered searches

update gaz_name set extents = (select st_setsrid(st_extent(shape),4167) from gaz_shape where feat_id = gaz_name.feat_id);

RETURN 1;
END
$body$
LANGUAGE plpgsql
SET search_path FROM CURRENT;

-- select gweb_update_gaz_shape();

-- -- Reduce number of decimal places...
-- -- This was to reduce the file size when we were dumping to a text file for uploading.
-- -- Not applicable to current implementation.
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




-- ----------------------------------------------------------------------------
-- Populate gaz_shape

-- Get points, lines and polys from the feature geometry. If there's more than one geometry for a feature than merge them into a multigeom as long as they're the same geom type.
-- Get ref points for lines and polys, and all points except those that already have points defined in the feature geom.

CREATE OR REPLACE function gazetteer.gweb_update_gaz_all_shapes()
RETURNS INT
AS
$body$
BEGIN

SET search_path TO gazetteer, gazetteer_web, public;

truncate gaz_all_shapes;

drop table if exists tmp_all_shapes1;
create temp table tmp_all_shapes1
(
   feat_id int not null,
   geom_type character(1) NOT NULL,
   geom geometry
);

--get merged geoms for all defined geometries. i.e features with multiple geometeries of the same type will be merged into multigeoms.
insert into tmp_all_shapes1 (feat_id, geom_type, geom )
select 
	g.feat_id, 
	g.geom_type, 
	st_union(ST_Force_2D(g.shape))
from 
   feature_geometry g
   join feature f on g.feat_id = f.feat_id
group by g.feat_id, g.geom_type;

create index tmp_fid on tmp_all_shapes1( feat_id );
analyze tmp_all_shapes1;

--get ref points for all except features that already have points defined as their geometry. If they're polygons or lines we also want the ref points.
insert into gaz_all_shapes (feat_id, geom_type, shape )
select 
	f.feat_id,
	'X',
	f.ref_point 
from 
   feature f
   join gaz_feature gf on gf.id = f.feat_id
where f.feat_id not in (select feat_id from tmp_all_shapes1 where geom_type='X')
group by f.feat_id, 2, f.ref_point;

insert into gaz_all_shapes (feat_id, geom_type, shape )
select
	feat_id, 
	geom_type, 
	geom
from 
tmp_all_shapes1;

ANALYZE gaz_all_shapes;
RETURN 1;
END
$body$
LANGUAGE plpgsql
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION gazetteer.gweb_update_web_database()
RETURNS INT
AS
$body$
DECLARE
    l_update VARCHAR(256);
BEGIN
    PERFORM gweb_update_gaz_code();
    PERFORM gweb_update_gaz_event();
    PERFORM gweb_update_gaz_feature();
    PERFORM gweb_update_gaz_name();
    PERFORM gweb_update_gaz_annotation();
    PERFORM gweb_update_gaz_shape();
    DROP TABLE IF EXISTS tmp_name_id;
    l_update = to_char(current_timestamp,'HH:MI DD-Mon-YYYY') || ' by ' || current_user;
    IF NOT EXISTS (SELECT * from system_code WHERE code_group='SYSI' AND code='WEBU') THEN
        INSERT INTO system_code( code_group, code, value, description )
        VALUES ('SYSI','WEBU',l_update,'Last web database update');
    ELSE
        UPDATE system_code SET
           value=l_update,
           description='Last web database update'
        WHERE
           code_group = 'SYSI' AND code='WEBU';
    END IF;
    RETURN 1;
END
$body$
LANGUAGE plpgsql
SET search_path FROM CURRENT;

-- SELECT gweb_update_web_database()
-- SELECT COUNT(*) FROM gazetteer_web.gaz_name

ALTER FUNCTION gazetteer.gweb_html_encode( TEXT ) OWNER TO gazetteer_dba;
ALTER FUNCTION gazetteer.gweb_update_gaz_code() OWNER TO gazetteer_dba;
ALTER FUNCTION gazetteer.gweb_update_gaz_event() OWNER TO gazetteer_dba;
ALTER FUNCTION gazetteer.gweb_update_gaz_feature() OWNER TO gazetteer_dba;
ALTER FUNCTION gazetteer.gweb_update_gaz_name() OWNER TO gazetteer_dba;
ALTER FUNCTION gazetteer.gweb_update_gaz_annotation() OWNER TO gazetteer_dba;
ALTER FUNCTION gazetteer.gweb_simplify_shapes( zmin INT, zmax INT ) OWNER TO gazetteer_dba;
ALTER FUNCTION gazetteer.gweb_update_web_database() OWNER TO gazetteer_dba;

GRANT EXECUTE ON FUNCTION gazetteer.gweb_html_encode( TEXT ) TO gazetteer_dba;
GRANT EXECUTE ON FUNCTION gazetteer.gweb_update_gaz_code() TO gazetteer_dba;
GRANT EXECUTE ON FUNCTION gazetteer.gweb_update_gaz_event() TO gazetteer_dba;
GRANT EXECUTE ON FUNCTION gazetteer.gweb_update_gaz_feature() TO gazetteer_dba;
GRANT EXECUTE ON FUNCTION gazetteer.gweb_update_gaz_name() TO gazetteer_dba;
GRANT EXECUTE ON FUNCTION gazetteer.gweb_update_gaz_annotation() TO gazetteer_dba;
GRANT EXECUTE ON FUNCTION gazetteer.gweb_simplify_shapes( zmin INT, zmax INT ) TO gazetteer_dba;
GRANT EXECUTE ON FUNCTION gazetteer.gweb_update_web_database() TO gazetteer_dba;
