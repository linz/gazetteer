
-- Script to build name_annotation data and feature_annotation data from import data
-- Uses data imported by load_migration_data.py

SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET client_min_messages=WARNING;

-- Clear name related errors

-- *******************************************************************

DROP TABLE IF EXISTS tmp_name_annot;

CREATE TABLE tmp_name_annot
(
    name_id INTEGER NOT NULL,
    annot_type VARCHAR(4) NOT NULL,
    annotation TEXT,
    is_feat CHAR(1) DEFAULT 'N',
    PRIMARY KEY (annot_type, name_id)
);

CREATE INDEX tmp_name_annot_name_id ON tmp_name_annot( name_id, annot_type );

-- History/origin/meaning

INSERT INTO tmp_name_annot (name_id, annot_type, annotation )
SELECT 
    distinct
    nm.name_id,
    'HORM',
    info_note
FROM
    data d
    JOIN tmp_name_map nm ON nm.id=d.id
WHERE
    feat_id IS NOT NULL AND
    coalesce(info_note,'') <> '';
    ;

-- For district statutory names, description after second sentence is part of HORM

DROP TABLE IF EXISTS tmp_disn_horm;

CREATE TEMP table tmp_disn_horm AS
SELECT
   d.id,
   regexp_replace(d.info_description,E'^\\[^\\.]*\\.\\s+','') as horm,
   CASE WHEN coalesce(d.info_note,'') = '' THEN '' ELSE ' ' || d.info_note END as horm2
FROM 
   data d
   JOIN tmp_name_map nm ON nm.id=d.id
WHERE
   d.src='DISN'
   and regexp_replace(d.info_description,E'^\\[^\\.]*\\.\\s+','') <> '';

DELETE FROM tmp_name_annot 
WHERE annot_type='HORM' AND name_id in (SELECT id FROM tmp_disn_horm);

INSERT INTO tmp_name_annot (name_id, annot_type, annotation )
SELECT 
    id,
    'HORM',
    horm || horm2
FROM
    tmp_disn_horm;

DROP TABLE tmp_disn_horm;

-- Land district 

drop table if exists tmp_districts;
drop table if exists tmp_districts2;

create temp table tmp_districts( district varchar(50) not null primary key );
insert into tmp_districts values
('North Auckland'),
('South Auckland'),
('Hawkes Bay'),
('Hawke''S Bay'),
('Gisborne'),
('Taranaki'),
('Wellington'),
('Nelson'),
('Marlborough'),
('Westland'),
('Canterbury'),
('Otago'),
('Southland');

create temp table tmp_districts2 as
select
  d1.district || ' & ' || d2.district
from 
  tmp_districts d1,
  tmp_districts d2
where
  d1.district <> d2.district;

insert into tmp_districts 
select * from tmp_districts2;

drop table tmp_districts2;
analyze tmp_districts;

-- delete from tmp_name_annot where annot_type='LDIS'
insert into tmp_name_annot( name_id, annot_type, annotation, is_feat )
SELECT
   id,
   'LDIS',
   initcap(replace(district,' and ',' & ')),
   'Y'
FROM
   data
WHERE
   feat_id IS NOT NULL AND
   initcap(replace(district,' and ',' & ')) IN (select district FROM tmp_districts);

drop table tmp_districts;

update tmp_name_annot
SET annotation=REPLACE(annotation,'Hawkes','Hawkes''s')
WHERE annot_type='LDIS' AND annotation like '%Hawkes%';

update tmp_name_annot
SET annotation=REPLACE(annotation,'Hawke''S','Hawkes''s')
WHERE annot_type='LDIS' AND annotation like '%Hawke''S%';

analyze tmp_name_annot;

-- delete from error where class='NANT' and subclass='BDIS'

DELETE FROM error WHERE class='NANT' and subclass='BDIS';
DELETE FROM error_class WHERE class='NANT' and subclass='BDIS';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('NANT','BDIS','Land district not recognized', 'NAME');

INSERT INTO error( id, class, subclass, error )
SELECT 
   distinct
   nm.name_id,
   'NANT',
   'BDIS',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || d.district || ': Unrecognized land district'
FROM
   data d
   JOIN tmp_name_map nm ON nm.id = d.id
   LEFT OUTER JOIN tmp_name_annot ON tmp_name_annot.name_id=nm.name_id AND annot_type='LDIS'
WHERE
   feat_id IS NOT NULL AND
   coalesce (district,'') <> '' AND
   district NOT ILIKE '%undersea%' AND
   district NOT ILIKE '%island%' AND district NOT ILIKE '%antarctica%' AND district NOT ILIKE '%ross sea%' AND
   tmp_name_annot.name_id IS NULL
   ;

-- select error from error where class='NANT' and subclass='BDIS'


-- Islands ..
-- delete from tmp_name_annot where annot_type='ISLD'
insert into tmp_name_annot( name_id, annot_type, annotation, is_feat )
SELECT
   id,
   'ISLD',
   regexp_replace(district,E'.*\\-\\s+',''),
   'Y'
FROM
   data
WHERE
   feat_id IS NOT NULL AND
   district ilike '%island%';


-- Reference information
-- delete from tmp_name_annot where annot_type='FLRF'
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
   nm.name_id,
   'FLRF',
   info_ref
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   coalesce(info_ref,'') <> '';

-- Crown protected areas ..
-- delete from tmp_name_annot where annot_type='CPAL';

insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   DISTINCT
   nm.name_id,
   'CPAL',
   trim( both from (
   regexp_replace(coalesce(cpa_section,''),E'^s','Section ') || ' ' ||
   coalesce(cpa_legislation,'')))
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   src = 'CPON' AND 
   (coalesce(cpa_section,'') <> '' OR
    coalesce(cpa_legislation,'') <> '');

-- Antarctic attributes SCAR height, SCAR id, SCAR recorded by

-- delete from tmp_name_annot where annot_type='SCAR';
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
   nm.name_id,
   'SCAR',
   'Y'
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   data.src like 'AN%';

-- Add maps shown on to the notes for the mark..

DROP TABLE IF EXISTS tmp_ant_maps;
CREATE TEMP TABLE tmp_ant_maps 
AS
SELECT
  distinct 
  nm.name_id,
  CASE WHEN COALESCE(ant_nz250000_map,'')<>'' THEN 
     E'\nShown on NZ 250000 map ' || ant_nz250000_map || '.'
  ELSE
     ''
  END 
  ||
  CASE WHEN COALESCE(ant_us250000_map,'')<>'' THEN 
     E'\nShown on US 250000 ' || ant_us250000_map || '.'
  ELSE
     ''
  END as maps
FROM
  data
  JOIN tmp_name_map nm ON nm.id = data.id
WHERE
  COALESCE(ant_nz250000_map,'')<>'' OR COALESCE(ant_us250000_map,'')<>'';

UPDATE tmp_name_annot
  SET annotation =
     annotation || (select maps FROM tmp_ant_maps WHERE name_id=tmp_name_annot.name_id)
  WHERE
      name_id IN (SELECT name_id FROM tmp_ant_maps) AND
      annot_type = 'NNOT';  
-- select * from tmp_name_annot where name_id IN  (SELECT id FROM tmp_ant_maps) and annot_type='NNOT'

DELETE FROM tmp_ant_maps WHERE name_id IN (SELECT name_id FROM tmp_name_annot WHERE annot_type='NNOT');

INSERT INTO tmp_name_annot( name_id, annot_type, annotation )
SELECT
   name_id,
   'NNOT',
   substring(maps from 2)
FROM
   tmp_ant_maps;

DROP TABLE tmp_ant_maps;
   

-- delete from tmp_name_annot where annot_type='SCID';
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
   nm.name_id,
   'SCID',
   scar_id
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   src like 'AN%' and
   coalesce(scar_id,'') <> '';
   
-- delete from tmp_name_annot where annot_type='SCRB';
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
   nm.name_id,
   'SCRB',
   scar_rec_by
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   src like 'AN%' and
   coalesce(scar_rec_by,'') <> '';

-- delete from tmp_name_annot where annot_type='SCHT';
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'SCHT',
   height
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   src like 'AN%' and
   coalesce(height,'') <> '';

-- Undersea feature attributes

-- delete from tmp_name_annot where annot_type='SCUF';
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
   nm.name_id,
   'SCUF',
   'Y'
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   data.src like 'US%';

-- delete from tmp_name_annot where annot_type='UFGT';
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'UFGT',
   geom_type
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   src in ('USON','USXN') AND 
   geom_type in ('point','line','polygon');

analyze tmp_name_annot;

-- delete from error where class='NANT' and subclass='BDIS'

DELETE FROM error WHERE class='NANT' and subclass='BDGT';
DELETE FROM error_class WHERE class='NANT' and subclass='BDGT';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('NANT','BDGT','Geometry type value not valid', 'NAME');

INSERT INTO error( id, class, subclass, error )
SELECT 
   distinct
    nm.name_id,
   'NANT',
   'BDGT',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || d.geom_type || ': Bad geometry type'
FROM
   data d
   JOIN tmp_name_map nm ON nm.id = d.id
WHERE
   feat_id IS NOT NULL AND
   coalesce (geom_type,'') <> '' AND
   geom_type not in ('point','line','polygon');

-- delete from tmp_name_annot where annot_type='UFAC';
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'UFAC',
   accuracy
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   src in ('USON','USXN') AND 
   coalesce(accuracy,'') <> '';

 
-- delete from tmp_name_annot where annot_type='UFRG';
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'UFRG',
   region
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   src in ('USON','USXN') AND 
   coalesce(region,'') <> '';

-- delete from tmp_name_annot where annot_type='UFAD';
insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'UFAD',
   replace(replace(regexp_replace(scufn,E'^.*\\((.*)\\).*$',E'\\1'),'. ',' '),' 0',' 200')
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   src in ('USON','USXN') AND 
   scufn like '%(%)%'; 

DELETE FROM error WHERE class='NANT' and subclass='BDSA';
DELETE FROM error_class WHERE class='NANT' and subclass='BDSA';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('NANT','BDSA','Invalid SCUFN accreditation date', 'NAME');

INSERT INTO error( id, class, subclass, error )
SELECT 
   distinct
    nm.name_id,
   'NANT',
   'BDSA',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || d.scufn || ': Bad SCUFN accreditation date'
FROM
   data d
   JOIN tmp_name_map nm ON nm.id = d.id
WHERE
   feat_id IS NOT NULL AND
   coalesce (scufn,'') <> '' AND
   nm.name_id NOT IN (SELECT name_id FROM tmp_name_annot WHERE annot_type='UFAD');

-- delete from tmp_name_annot where annot_type='UFGP';

insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'UFGP',
   CASE WHEN gebco THEN 'Y' ELSE 'N' END
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   src in ('USON','USXN') AND 
   gebco IS NOT NULL;

-- delete from tmp_name_annot where annot_type='NTDC';

insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'NTDC',
   desc_code
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   desc_code <> '';

-- delete from tmp_name_annot where annot_type='NTAR';

insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'NTAR',
   accuracy_rating::varchar
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   accuracy_rating IS NOT NULL;

-- delete from tmp_name_annot where annot_type='DOCC';

insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'DOCC',
   conservancy
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   conservancy <> '';

-- delete from tmp_name_annot where annot_type='DOCR';

insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
   distinct
    nm.name_id,
   'DOCR',
   doc_cons_unit_no
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
WHERE
   feat_id IS NOT NULL AND
   doc_cons_unit_no <> '';


-- delete from tmp_name_annot where annot_type='MGRS';

insert into tmp_name_annot( name_id, annot_type, annotation )
SELECT
    nm.name_id,
   'MGRS',
   array_to_string( array_agg(ds.description || '.xls (line ' || data.lineno || ')'),E'\n')
FROM
   data
   JOIN tmp_name_map nm ON nm.id = data.id
   JOIN data_source ds ON data.src=ds.src
WHERE
   feat_id IS NOT NULL
GROUP BY
   nm.name_id
   ;


-- delete from error where class='NANT' and subclass='BDIS'

DELETE FROM error WHERE class='NANT' and subclass='FADP';
DELETE FROM error_class WHERE class='NANT' and subclass='FADP';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('NANT','FADP','Feature annotation inconsistent', 'FEAT');

DROP TABLE IF EXISTS tmp_dup_fant;
CREATE TEMP table tmp_dup_fant
AS
SELECT
   d.feat_id,
   a.annot_type,
   count(distinct a.annotation)
from
   tmp_name_annot a
   join data d on d.id=a.name_id
where
   a.is_feat='Y'
group by
   d.feat_id,
   a.annot_type
having 
   count(distinct a.annotation) > 1;

INSERT INTO error( id, class, subclass, error )
SELECT 
   DISTINCT
    d.feat_id,
   'NANT',
   'FADP',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Inconsistent feature annotation type ' || a.annot_type || ': ' || a.annotation
FROM
   data d
   JOIN tmp_name_map nm ON nm.id = d.id
   join tmp_name_annot a on d.id=a.name_id
   join tmp_dup_fant f on d.feat_id=f.feat_id and a.annot_type=f.annot_type
WHERE
   d.feat_id IS NOT NULL
   ;
       
ANALYZE tmp_name_annot;
















