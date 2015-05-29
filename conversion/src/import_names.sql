
-- Script to load name table from import data
-- Uses data imported by load_migration_data.py

SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET client_min_messages=WARNING;

-- *******************************************************************
-- Setup the mapping of ids from source names to the target names, 
-- incorporates merging of names in the data_merge_replace table

DROP TABLE IF EXISTS tmp_merged1;

CREATE TEMP TABLE tmp_merged1 AS 
SELECT 
   greatest(id1,id2) as id1,
   least(id1,id2) as id2
FROM 
   data_merge_replace dm
WHERE
   id1 IS NOT NULL AND id2 IS NOT NULL AND
   id1 != id2 AND
   action = 'M';

CREATE INDEX tmp_merged1_id1 ON tmp_merged1(id1);
ANALYZE tmp_merged1;

DROP TABLE IF EXISTS tmp_merged2;
CREATE TEMP TABLE tmp_merged2 AS
WITH RECURSIVE t1 ( id1, id2 ) AS
(
    SELECT id1, id2 FROM tmp_merged1
    UNION ALL
    SELECT t1.id1, tmp_merged1.id2
    FROM t1 JOIN tmp_merged1 ON t1.id2=tmp_merged1.id1
)
SELECT
    id1, MIN(id2) AS id2
FROM 
    t1
GROUP BY
    id1;

CREATE INDEX tmp_merged2_id1 ON tmp_merged1(id1);
ANALYZE tmp_merged2;

DROP TABLE IF EXISTS tmp_name_map;
CREATE TABLE tmp_name_map
AS
SELECT
   data.id as id,
   COALESCE(t.id2,data.id) as name_id,
   CASE WHEN t.id2 IS NOT NULL OR DATA.id IN (SELECT id2 FROM tmp_merged2) 
   THEN 'M' ELSE 'U'
   END as status
FROM
   data
   LEFT OUTER JOIN tmp_merged2 t ON t.id1 = data.id;

CREATE INDEX tmp_name_map_id ON tmp_name_map( id );
CREATE INDEX tmp_name_map_name_id ON tmp_name_map( name_id );
ANALYZE tmp_name_map;

DROP TABLE IF EXISTS tmp_name_status;

-- Notes from discussion with Wendy 1/2/2012
-- Update data set status='Approved' where src='USON' and nzgb_ref is not null and nzgb_date like '201%'

-- update data set status='Validated' where src='ANON' and nzgb_date='2009-05-29';
-- Check approved names have nzgb references?

-- For CPON source - Check that "Approved Doc" status  matches "doc_gaz_ref is not null"


CREATE TEMP TABLE tmp_name_status
(
    id INTEGER NOT NULL PRIMARY KEY,
    name_id INTEGER NOT NULL,
    feat_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    process CHAR(4) NOT NULL,
    status CHAR(4) NOT NULL
    -- , event CHAR(4) DEFAULT ''
);

INSERT INTO tmp_name_status
SELECT 
    d.id,
    map.name_id,
    d.feat_id,
    case WHEN d.name=upper(d.name) THEN initcap(name) ELSE d.name END,
    sm.name_process,
    sm.name_status
FROM
    data d
    JOIN tmp_name_map map on map.id = d.id
    JOIN status_mapping sm
      ON sm.src=d.src AND sm.status = COALESCE(d.status,'')
WHERE
    feat_id IS NOT NULL;

-- UPDATE tmp_name_status SET status='STAT', event='CURR' WHERE id IN
--    (SELECT id FROM data WHERE  src='TSON' and nzgb_ref is not null);
-- 
-- UPDATE tmp_name_status SET event='VLDT' WHERE id IN
--    (SELECT id FROM data WHERE  src='ANON' and nzgb_date='2009-05-29');
-- 
-- UPDATE tmp_name_status SET status='OFAS', event='ADPT' WHERE id IN
--    (SELECT id FROM data WHERE src='USON' and nzgb_ref is not null and nzgb_date like '201%');   
-- 
-- UPDATE tmp_name_status SET event='ASGN' where status='OFCL' AND id IN
--    (SELECT id FROM data WHERE nzgb_date >= '2008' and info_note ilike '%assign%');   
-- 
-- UPDATE tmp_name_status SET event='ALTR' where status='OFCL' AND id IN
--    (SELECT id FROM data WHERE nzgb_date >= '2008' and info_note ilike '%alter%');   

DELETE FROM error WHERE class='NAME' and subclass='STTS';
DELETE FROM error_class WHERE class='NAME' and subclass='STTS';
   
INSERT INTO error_class( class, subclass, description )
VALUES ('NAME','STTS','Invalid source/status for name');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NAME',
   'STTS',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || COALESCE(d.status,'') || ': Invalid source, status for name'
FROM
   data d
WHERE
   feat_id IS NOT NULL AND
   id NOT IN (SELECT id FROM tmp_name_status);

DELETE FROM error WHERE class='NAME' and subclass='STIN';
DELETE FROM error_class WHERE class='NAME' and subclass='STIN';
   
INSERT INTO error_class( class, subclass, description )
VALUES ('NAME','STIN','Inconsistent status for merged names');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NAME',
   'STIN',
   t.name_id::VARCHAR || ': ' || d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || COALESCE(d.status,'') || ': Inconsistent status of merged names' 
FROM
   data d
   join tmp_name_map t on t.id=d.id
WHERE
   t.name_id IN
   (SELECT 
       name_id 
    FROM 
       tmp_name_status
    GROUP BY name_id
    HAVING COUNT(distinct status) > 1
);

DELETE FROM error WHERE class='NAME' and subclass='PRIN';
DELETE FROM error_class WHERE class='NAME' and subclass='PRIN';
   
INSERT INTO error_class( class, subclass, description )
VALUES ('NAME','PRIN','Inconsistent process for merged names');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NAME',
   'PRIN',
   t.name_id::VARCHAR || ': ' || d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || COALESCE(d.status,'') || ': Inconsistent process of merged names' 
FROM
   data d
   join tmp_name_map t on t.id=d.id
WHERE
   t.name_id IN
   (SELECT 
       name_id 
    FROM 
       tmp_name_status
    GROUP BY name_id
    HAVING COUNT(distinct process) > 1
);

-- select * from error where class='NAME' and subclass='STIN';

DELETE FROM error WHERE class='NAME' and subclass='NMIN';
DELETE FROM error_class WHERE class='NAME' and subclass='NMIN';
   
INSERT INTO error_class( class, subclass, description )
VALUES ('NAME','NMIN','Inconsistent name for merged names');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NAME',
   'NMIN',
   t.name_id::VARCHAR || ': ' || d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || COALESCE(d.name,'') || ': Inconsistent name of merged names' 
FROM
   data d
   join tmp_name_map t on t.id=d.id
WHERE
   t.name_id IN
   (SELECT 
       name_id 
    FROM 
       tmp_name_status
    GROUP BY name_id
    HAVING COUNT(distinct name) > 1
);
;

-- select * from error where class='NAME' and subclass='NMIN';

DROP TABLE IF EXISTS tmp_name_auth;
CREATE TEMP TABLE tmp_name_auth
(
    id INT NOT NULL PRIMARY KEY,
    authority CHAR(4) NOT NULL,
    auth_ref VARCHAR(100),
    auth_date VARCHAR(30),
    notes TEXT
);


INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'NZGB', nzgb_ref, nzgb_date, info_origin
FROM
  data
WHERE
  nzgb_ref is not null;

  
INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'APNC', ant_pn_ref, NULL, NULL
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'ANCN' AND
  ant_pn_ref IS NOT NULL;

INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'APGZ', ant_pgaz_ref, NULL, NULL
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'ANCN' AND
  ant_pgaz_ref IS NOT NULL;


INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'DOCG', doc_gaz_ref, doc_gaz_date, cpa_legislation || ' ' || cpa_section
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'CPON' AND
  doc_gaz_ref IS NOT NULL; 


INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'STAT', stat_legislation || ' ' || stat_leg_page, stat_leg_date, NULL
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'DISN' AND
  stat_legislation IS NOT NULL; 

INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'TOWS', treaty_legislation || ' ' || treaty_page, treaty_date, null
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'TSON' AND
  treaty_legislation IS NOT NULL; 

INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'USEA', null , null, info_ref
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'USON'; 


INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'TOPO', null , null, edition
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'NZRN'; 

INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'TOPO', null , null, null
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'OIRN'; 
 
INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'TOPO', null , null, info_note
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'NZXN'; 

INSERT INTO tmp_name_auth (id, authority, auth_ref, auth_date, notes )
SELECT
  id, 'USEA', null , null, info_ref
FROM
  data
WHERE
  id NOT IN (SELECT id FROM tmp_name_auth) AND
  src = 'USXN'; 
        
UPDATE tmp_name_auth 
SET auth_date=NULL 
WHERE auth_date !~ E'^\\d\\d\\d\\d\\-\\d\\d\\-\\d\\d$' AND auth_date !~ E'^\\d\\d\\d\\d$';

-- select * from tmp_name_auth
-- select nzgb_date, * from data where nzgb_ref is not null and nzgb_date !~ E'^\\d\\d\\d\\d\\-\\d\\d\\-\\d\\d$' and nzgb_date !~ E'^\\d\\d\\d\\d$'
-- select src, count(*) from data where feat_id is not null and id not in (select id from tmp_name_auth) group by src

DROP TABLE IF EXISTS tmp_name;
CREATE TABLE tmp_name
(
    id INTEGER NOT NULL PRIMARY KEY,
    feat_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    process CHAR(4) NOT NULL,
    status CHAR(4) NOT NULL,
    -- event CHAR(4) NOT NULL,
    -- authority CHAR(4) NOT NULL,
    -- auth_ref VARCHAR(100),
    -- auth_date VARCHAR(30),
    notes TEXT
);

INSERT INTO tmp_name (id, feat_id, name, process, status, 
    -- event, authority, auth_ref, auth_date, 
    notes )
SELECT 
   n.name_id,
   MIN(n.feat_id),
   MIN(n.name),
   MIN(n.process),
   MIN(n.status),
   -- n.event,
   -- min(a.authority),
   -- min(a.auth_ref),
   -- min(a.auth_date),
   min(a.notes)
FROM
   tmp_name_status n
   LEFT OUTER JOIN tmp_name_auth a ON a.id = n.id
GROUP BY 
   n.name_id;

CREATE INDEX tmp_name_fid ON tmp_name( feat_id ); 
CREATE INDEX tmp_name_name ON tmp_name( name );

-- select distinct status, authority from tmp_name;
-- select count(*) from tmp_name
