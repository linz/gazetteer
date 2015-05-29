
-- Script to build name_event data from import data
-- Uses data imported by load_migration_data.py

SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET client_min_messages=WARNING;

-- Clear name related errors

-- *******************************************************************

DROP TABLE IF EXISTS tmp_name_event;

CREATE TABLE tmp_name_event
(
    id SERIAL PRIMARY KEY,
    name_id INTEGER NOT NULL,
    event_date date,
    event_type character(4) NOT NULL,
    authority character(4) NOT NULL,
    event_reference text,
    notes text
);

CREATE INDEX tmp_name_event_event_name ON tmp_name_event( event_type, name_id );


-- Process NZGB gazettal events.  

DROP TABLE IF EXISTS tmp_gaz;
CREATE TEMP TABLE tmp_gaz
(
    name_id INT PRIMARY KEY,
    nzgb_ref varchar(50), 
    nzgb_date varchar(30),
    nzgb_date_date date,
    nzgb_year varchar(30),
    nzgb_no varchar(10),
    nzgb_page varchar(10),
    calc_ref varchar(50)
);

INSERT INTO tmp_gaz (
    name_id,
    nzgb_ref,
    nzgb_date,
    nzgb_date_date,
    nzgb_year,
    nzgb_no,
    nzgb_page,
    calc_ref
    )
SELECT 
    id, 
    nzgb_ref,  
    nzgb_date,
    CASE 
    WHEN nzgb_date ~ E'^\\d{4}\\-\\d\\d\\-\\d\\d$' THEN
       nzgb_date::date
    WHEN nzgb_date ~ E'^\\d{4}($|[^\\d])' THEN
       (substring(nzgb_date from 1 for 4) || '-01-01')::date
    ELSE
       NULL
    END,
    regexp_replace(nzgb_date,E'\\-\\d\\d\\-\\d\\d$',''),
    nzgb_no, 
    nzgb_page,
    regexp_replace(nzgb_date,E'\\-\\d\\d\\-\\d\\d$','') || ' (' || nzgb_no || ') p.' || nzgb_page::varchar
from 
    data 
where 
    nzgb_ref is not null or  nzgb_date is not null or nzgb_no is not null or nzgb_page is not null;

-- select * from tmp_gaz WHERE nzgb_ref <> calc_ref;    

-- Reference doesn't match component parts

DELETE FROM error WHERE class='NEVT' and subclass='BDYR';
DELETE FROM error_class WHERE class='NEVT' and subclass='BDYR';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','BDYR','Gazetteer reference doesn''t match year/no/page');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'BDYR',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || t.nzgb_ref || ' <> ' || t.calc_ref || ': Warning! Gazetter reference doesn''t match components'
FROM
   data d
   JOIN tmp_gaz t on t.name_id = d.id
WHERE
   t.nzgb_ref <> t.calc_ref
   ;

-- SELECT * FROM error WHERE class = 'NEVT' and subclass='BDYR'
  
-- Reference date cannot be used...

DELETE FROM error WHERE class='NEVT' and subclass='BDDT';
DELETE FROM error_class WHERE class='NEVT' and subclass='BDDT';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','BDDT','Gazette date is not useable');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'BDDT',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || coalesce(t.nzgb_date,'') || ': Gazette date is not usable'
FROM
   tmp_gaz t
   join data d on d.id = t.name_id
WHERE
   t.nzgb_date_date IS NULL
   ;

-- SELECT * FROM error WHERE class = 'NEVT' and subclass='BDDT'
   
-- Missing gazette reference?

DELETE FROM error WHERE class='NEVT' and subclass='MSGR';
DELETE FROM error_class WHERE class='NEVT' and subclass='MSGR';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','MSGR','Official name doesn''t have a gazette reference');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'MSGR',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Official name doesn''t have gazetter reference'
FROM
   data d
   LEFT OUTER JOIN tmp_gaz t on t.name_id = d.id
WHERE
   d.src IN ('NZON','NYON','RYON','OION') AND 
   t.name_id IS NULL
   ;
   
-- SELECT substring(error from 1 for 4), count(*) FROM error WHERE class = 'NEVT' and subclass='MSGR' group by substring(error from 1 for 4)
-- SELECT * FROM error WHERE class = 'NEVT' and subclass='MSGR'


INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
select
    distinct
    nm.name_id,
    nzgb_date_date,
    CASE WHEN nzgb_no='HON' THEN 'NZGH' ELSE 'NZGZ' END,
    CASE WHEN nzgb_no='HON' THEN 'NZGH' ELSE 'NZGB' END,
    nzgb_ref,
    ''
FROM
    tmp_gaz
    JOIN tmp_name_map nm ON tmp_gaz.name_id=nm.id
WHERE
    nzgb_date_date IS NOT NULL;

INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
select
    distinct
    nm.name_id,
    '1948-07-29'::date,
    'NZGZ',
    'NZGB',
    '1948 (42) p.939',
    ''
FROM
    tmp_gaz
    JOIN tmp_name_map nm ON tmp_gaz.name_id=nm.id
    WHERE nzgb_no='HON';    

DROP TABLE tmp_gaz;

-- -----------------------------------------------------------------
-- Treaty settlement events

INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
select
    distinct
    nm.name_id,
    CASE WHEN treaty_date ~ E'^\\d{4}\\-\\d\\d\\-\\d\\d$' THEN treaty_date::date ELSE NULL END,
    'TSLG',
    'TOWS',
    'Section ' || treaty_page || ' ' || treaty_legislation,
    ''
FROM
    data
    JOIN tmp_name_map nm ON nm.id=data.id
WHERE
     treaty_legislation <> '' or treaty_date <> '' or treaty_page <> '';

-- Missing gazette reference?


DELETE FROM error WHERE class='NEVT' and subclass='TSER';
DELETE FROM error_class WHERE class='NEVT' and subclass='TSER';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','TSER','Treat settlement info not correct (missing or bad date)');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'TSER',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Treaty settlement information not correct (missing, or bad date)'
FROM
   data d
WHERE
   (treaty_legislation <> '' or treaty_date <> '' or treaty_page <> '')
   AND (coalesce(treaty_legislation,'') = '' OR
     coalesce(treaty_page,'') !~ E'^\\d+(\\-\\d+)?$' OR
     coalesce(treaty_date,'') !~ E'^\\d{4}\\-\\d\\d\\-\\d\\d$');


DELETE FROM error WHERE class='NEVT' and subclass='TSMS';
DELETE FROM error_class WHERE class='NEVT' and subclass='TSMS';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','TSMS','Treaty settlement information missing');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'TSMS',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Treaty settlement information missing'
FROM
   data d
   JOIN tmp_name_map nm ON nm.id=d.id
   
WHERE
   src = 'TSON' AND 
   nm.name_id NOT IN (SELECT name_id FROM tmp_name_event WHERE event_type='TSLG');

-- SELECT * FROM error WHERE class='NEVT' AND subclass IN ('TSER','TSMS');

-- -------------------------------------------------------------
-- Process DOC gazettal events.  

DROP TABLE IF EXISTS tmp_gaz;
CREATE TEMP TABLE tmp_gaz
(
    name_id INT PRIMARY KEY,
    doc_ref varchar(50), 
    doc_date varchar(30),
    doc_date_date date,
    doc_year varchar(30),
    doc_no varchar(10),
    doc_page varchar(10),
    calc_ref varchar(50)
);

INSERT INTO tmp_gaz (
    name_id,
    doc_ref,
    doc_date,
    doc_date_date,
    doc_year,
    doc_no,
    doc_page,
    calc_ref
    )
SELECT 
    id, 
    doc_gaz_ref,  
    doc_gaz_date,
    CASE 
    WHEN doc_gaz_date ~ E'^\\d{4}\\-\\d\\d\\-\\d\\d$' THEN
       doc_gaz_date::date
    WHEN doc_gaz_date ~ E'^\\d\\d?\\/\\d\\d?\\/\\d{4}$' THEN
       regexp_replace(doc_gaz_date,E'^(\\d\\d?)\\/(\\d\\d?)\\/(\\d{4})$',E'\\3-\\2-\\1')::date
    WHEN doc_gaz_date ~ E'^\\d{4}($|[^\\d])' THEN
       (substring(doc_gaz_date from 1 for 4) || '-01-01')::date
    ELSE
       NULL
    END,
    regexp_replace(regexp_replace(doc_gaz_date,E'\\-\\d\\d\\-\\d\\d$',''),E'^\\d\\d?\\/\\d\\d?\\/',''),
    doc_gaz_no, 
    doc_gaz_page,
    regexp_replace(regexp_replace(doc_gaz_date,E'\\-\\d\\d\\-\\d\\d$',''),E'^\\d\\d?\\/\\d\\d?\\/','')
    || ' (' || doc_gaz_no || ') p.' || doc_gaz_page::varchar
from 
    data 
where 
    doc_gaz_ref is not null or  doc_gaz_date is not null or doc_gaz_no is not null or doc_gaz_page is not null;

-- select * from tmp_gaz WHERE doc_ref <> calc_ref;    

-- Reference doesn't match component parts

DELETE FROM error WHERE class='NEVT' and subclass='DCBR';
DELETE FROM error_class WHERE class='NEVT' and subclass='DCBR';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','DCBR','DOC gazette reference doesn''t match year/no/page');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'DCBR',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || t.doc_ref || ' <> ' || t.calc_ref || ': Warning! DOC gazetter reference doesn''t match components'
FROM
   data d
   JOIN tmp_gaz t on t.name_id = d.id
WHERE
   t.doc_ref <> t.calc_ref
   ;

-- SELECT * FROM error WHERE class = 'NEVT' and subclass='DCBR'
  
-- Reference date cannot be used...

DELETE FROM error WHERE class='NEVT' and subclass='DCBD';
DELETE FROM error_class WHERE class='NEVT' and subclass='DCBD';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','DCBD','DOC gazette date is not useable');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'DCBD',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || coalesce(t.doc_date,'') || ': DOC gazette date is not usable'
FROM
   tmp_gaz t
   join data d on d.id = t.name_id
WHERE
   t.doc_date_date IS NULL
   ;

-- SELECT * FROM error WHERE class = 'NEVT' and subclass='BDDT'
   
-- Missing gazette reference? OK if have NZGB gazettal?

DELETE FROM error WHERE class='NEVT' and subclass='DCMG';
DELETE FROM error_class WHERE class='NEVT' and subclass='DCMG';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','DCMG','CPA name doesn''t have DOC or NZGB gazette reference');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'DCMG',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': CPA name doesn''t have DOC or NZGB gazette reference'
FROM
   data d
   JOIN tmp_name_map nm ON nm.id=d.id
   LEFT OUTER JOIN tmp_gaz t on t.name_id = d.id
WHERE
   d.src = 'CPON' AND
   nm.name_id NOT IN (SELECT name_id FROM tmp_name_event WHERE event_type='NZGZ') AND 
   t.name_id IS NULL
   ;
   
-- SELECT substring(error from 1 for 4), count(*) FROM error WHERE class = 'NEVT' and subclass='MSGR' group by substring(error from 1 for 4)
-- SELECT * FROM error WHERE class = 'NEVT' and subclass='MSGR'


INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
select
    distinct
    nm.name_id,
    doc_date_date,
    'DOCG',
    'DOCG',
    doc_ref,
    ''
FROM
    tmp_gaz
    JOIN tmp_name_map nm ON tmp_gaz.name_id=nm.id
WHERE
    doc_date_date IS NOT NULL;

-- select * from tmp_name_event where event_type='DOCG'
   
DROP TABLE tmp_gaz;

-- ---------------------------------------------------------------------------------------
-- Antarctic gazetteer names

-- delete FROM tmp_name_event WHERE event_type='CLCT' AND authority='ANPG';
INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
SELECT
    distinct
    nm.name_id,
    CASE 
    WHEN ant_pn_ref ~ E'\\d\\d\\/\\d\\d/\\d{4}' THEN
        regexp_replace(ant_pn_ref,E'^(?:.*[^\\d])?(\\d\\d?)\\/(\\d\\d?)\\/(\\d{4})(?:[^\\d].*)?$',E'\\3-\\2-\\1')::date  
    WHEN ant_pn_ref ~ E'November\\s+\\d{4}' THEN
        regexp_replace(ant_pn_ref,E'^(?:.*[^\\w])?November\\s+(\\d{4})(?:[^\\d].*)?$',E'\\1-11-01')::date  
    WHEN ant_pgaz_ref ~ E'\\d{4}($|[^\\d])' THEN
       regexp_replace(ant_pgaz_ref,E'^(?:.*[^\\d])?(\\d{4})(?:[^\\d].*)?$',E'\\1-01-01')::date  
    WHEN ant_pn_ref ~ E'\\d{4}($|[^\\d])' THEN
       regexp_replace(ant_pn_ref,E'^(?:.*[^\\d])?(\\d{4})(?:[^\\d].*)?$',E'\\1-01-01')::date  
    ELSE
        NULL
    END,
    'CLCT',
    CASE WHEN ant_pn_ref IS NULL THEN 'APGZ' ELSE 'APNC' END,
    CASE WHEN ant_pn_ref IS NULL THEN 
        ant_pgaz_ref
    ELSE
        ant_pn_ref || COALESCE(': ' || ant_pgaz_ref, '')
    END,
    ''      
FROM data
    JOIN tmp_name_map nm ON nm.id=data.id
WHERE
    ant_pn_ref IS NOT null OR ant_pgaz_ref IS NOT null;
-- select * from tmp_name_event where event_type='CLCT' and authority='ANPG'

-- delete from error where class='NEVT' and subclass='ACND' 

DELETE FROM error WHERE class='NEVT' and subclass='ACND';
DELETE FROM error_class WHERE class='NEVT' and subclass='ACND';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','ACND','Cannot determine antarctica name collection event date from ANPC or Prov Gaz ref');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'ACND',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Cannot discern antarctica name collection event date from ANPC or Prov Gaz references'
FROM
   data d
   JOIN tmp_name_map nm ON nm.id=d.id
   JOIN tmp_name_event t ON t.name_id = nm.name_id
WHERE
   t.event_type='CLCT' AND t.authority='ANPG' AND t.event_date IS NULL;

-- select * from error where class='NEVT' and subclass='ACND'
-- select ant_pn_ref,ant_pgaz_ref from data where id in (select id from error where class='NEVT' and subclass='ACND')

-- --------------------------------------------------------------------------
-- Revoking gazetter reference for removed/replaced names


DROP TABLE IF EXISTS tmp_gaz;
CREATE TEMP TABLE tmp_gaz
(
    name_id INT PRIMARY KEY,
    rev_ref varchar(50), 
    rev_date varchar(30),
    rev_date_date date,
    rev_year varchar(30),
    rev_no varchar(10),
    rev_page varchar(10),
    calc_ref varchar(50)
);

INSERT INTO tmp_gaz (
    name_id,
    rev_ref,
    rev_date,
    rev_date_date,
    rev_year,
    rev_no,
    rev_page,
    calc_ref
    )
SELECT 
    id, 
    rev_gaz_ref,  
    rev_gaz_date,
    CASE 
    WHEN rev_gaz_date ~ E'^\\d{4}\\-\\d\\d\\-\\d\\d$' THEN
       rev_gaz_date::date
    WHEN rev_gaz_date ~ E'^\\d\\d?\\/\\d\\d?\\/\\d{4}$' THEN
       regexp_replace(rev_gaz_date,E'^(\\d\\d?)\\/(\\d\\d?)\\/(\\d{4})$',E'\\3-\\2-\\1')::date
    WHEN rev_gaz_date ~ E'^\\d{4}($|[^\\d])' THEN
       (substring(rev_gaz_date from 1 for 4) || '-01-01')::date
    ELSE
       NULL
    END,
    regexp_replace(regexp_replace(rev_gaz_date,E'\\-\\d\\d\\-\\d\\d$',''),E'^\\d\\d?\\/\\d\\d?\\/',''),
    rev_gaz_no, 
    rev_gaz_page,
    regexp_replace(regexp_replace(rev_gaz_date,E'\\-\\d\\d\\-\\d\\d$',''),E'^\\d\\d?\\/\\d\\d?\\/','')
    || ' (' || rev_gaz_no || ') p.' || rev_gaz_page::varchar
from 
    data 
where 
    rev_gaz_ref is not null or  rev_gaz_date is not null or rev_gaz_no is not null or rev_gaz_page is not null;

-- select * from tmp_gaz WHERE rev_ref <> calc_ref;    

-- Reference doesn't match component parts

DELETE FROM error WHERE class='NEVT' and subclass='RVBR';
DELETE FROM error_class WHERE class='NEVT' and subclass='RVBR';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','RVBR','Revoking gazette reference doesn''t match year/no/page');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'RVBR',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || t.rev_ref || ' <> ' || t.calc_ref || ': Warning! Revoke gazetter reference doesn''t match components'
FROM
   data d
   JOIN tmp_gaz t on t.name_id = d.id
WHERE
   t.rev_ref <> t.calc_ref
   ;

-- SELECT * FROM error WHERE class = 'NEVT' and subclass='RVBR'
  
-- Reference date cannot be used...

DELETE FROM error WHERE class='NEVT' and subclass='RVBD';
DELETE FROM error_class WHERE class='NEVT' and subclass='RVBD';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','RVBD','Revoking gazette date is  badly formatted');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'RVBD',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || coalesce(t.rev_date,'') || ': Revoke gazette date is not usable'
FROM
   tmp_gaz t
   join data d on d.id = t.name_id
WHERE
   t.rev_date_date IS NULL
   ;

-- SELECT * FROM error WHERE class = 'NEVT' and subclass='RVBD'
   
-- Missing gazette reference

-- Try to find missing gazette references ...

-- Candidates are those with a unique name for a feature (otherwise ambiguous which is being revoked)
-- Also need a unique official event for the feature in the tmp_name_event table.

DROP TABLE IF EXISTS tmp_missing_revt;
CREATE TABLE tmp_missing_revt AS
SELECT 
   nm.name_id as name_id, 
   d.feat_id,
   MAX(nv.id) AS evt_id,
   COUNT(nv.id) as evt_count
FROM   
   data d
   JOIN tmp_name_map nm ON nm.id=d.id
   LEFT OUTER JOIN tmp_gaz t on t.name_id = d.id
   LEFT OUTER JOIN data d2 ON d2.src='NZXN' AND d2.feat_id=d.feat_id AND d2.id <> d.id
   LEFT OUTER JOIN data d3 ON d3.feat_id=d.feat_id AND d3.id != d.id
   LEFT OUTER JOIN tmp_name_map nm3 ON nm3.id=d3.id
   LEFT OUTER JOIN tmp_name_event nv ON nv.name_id=nm3.name_id -- AND nv.event_type='NZGZ'
WHERE
   d.src = 'NZXN' AND
   d2.id IS NULL AND
   t.name_id IS NULL
GROUP BY
   nm.name_id,
   d.feat_id
HAVING
   COUNT(nv.id) = 1
;
   
INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
select
    distinct
    nm.name_id,
    rev_date_date,
    CASE WHEN rev_no='HON' THEN 'NZGS' ELSE 'NZGR' END,
    CASE WHEN rev_no='HON' THEN 'NZGH' ELSE 'NZGB' END,
    rev_ref,
    ''
FROM
    tmp_gaz
    JOIN tmp_name_map nm ON tmp_gaz.name_id=nm.id
WHERE
    rev_date_date IS NOT NULL;

DELETE FROM error WHERE class='NEVT' and subclass='RVIN';
DELETE FROM error_class WHERE class='NEVT' and subclass='RVIN';

INSERT INTO error_class( class, subclass, description, info )
VALUES ('NEVT','RVIN','Info only: Revoking event inferred from other name of feature', 'Y');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'RVIN',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Info only, Revoking event inferred from other name of feature'
FROM
   data d
   JOIN tmp_missing_revt tm ON tm.name_id=d.id
   JOIN tmp_name_event ev ON ev.id=tm.evt_id;

INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
select
    distinct
   tm.name_id,
   ev.event_date,
   'NZGR',
   ev.authority,
   ev.event_reference,
   ev.notes
FROM
   tmp_missing_revt tm
   JOIN tmp_name_event ev ON ev.id=tm.evt_id;


DELETE FROM error WHERE class='NEVT' and subclass='MSRR';
DELETE FROM error_class WHERE class='NEVT' and subclass='MSRR';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','MSRR','Removed/replaced name doesn''t have revoking gazette reference');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'MSRR',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Removed/replaced name doesn''t have revoking gazetter reference'
FROM
   data d
   JOIN tmp_name_map nm ON nm.id=d.id
   LEFT OUTER JOIN tmp_name_event t on t.name_id = nm.name_id and t.event_type='NZGR'
WHERE
   d.src = 'NZXN' AND
   t.name_id IS NULL
   ;
   
-- SELECT * FROM error WHERE class = 'NEVT' and subclass='MSRR'


-- select * from tmp_name_event where event_type='DOCG'
   
DROP TABLE tmp_gaz;


-- -----------------------------------------------------------------------------
-- Revoke treaty settlements ...

DELETE FROM error WHERE class='NEVT' and subclass='TRBL';
DELETE FROM error_class WHERE class='NEVT' and subclass='TRBL';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','TRBL','Treaty legislation bad - doesn''t include year of act');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'TRBL',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Invalid revocation treaty legislation - no date'
FROM
   data d
WHERE
   d.feat_id IS NOT NULL AND 
   (
	rev_treaty_date != '' or
	rev_treaty_page != '' or
	rev_treaty_legislation != ''
    )
    and coalesce(rev_treaty_legislation,'') !~ E'\\s\\d{4}$';
-- select * from error where class='NEVT' and subclass='TRBL'

DELETE FROM error WHERE class='NEVT' and subclass='TRBD';
DELETE FROM error_class WHERE class='NEVT' and subclass='TRBD';

INSERT INTO error_class( class, subclass, description )
VALUES ('NEVT','TRBD','Invalid treaty settlement revocation date');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'TRBD',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Invalid treaty revocation treaty date'
FROM
   data d
WHERE
   d.feat_id IS NOT NULL AND 
   (
	rev_treaty_date != '' or
	rev_treaty_page != '' or
	rev_treaty_legislation != ''
    )
    and rev_treaty_legislation ~ E'\\s\\d{4}$'
    and coalesce(rev_treaty_date,'') !~ E'^\\d{4}\\-\\d\\d\\-\\d\\d$';
-- select * from error where class='NEVT' and subclass='TRBD'
   

-- delete from tmp_name_event where event_type='TSLR';

INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
select
    distinct
    nm.name_id,
    CASE 
    WHEN rev_treaty_date ~ E'^\\d{4}\\-\\d\\d\\-\\d\\d$' THEN rev_treaty_date::date 
    ELSE regexp_replace(rev_treaty_legislation,E'.*(\\d{4})$',E'\\1-01-01')::date
    END,
    'TSLR',
    'TOWS',
    COALESCE('Section ' || rev_treaty_page::varchar || ' ','') || rev_treaty_legislation,
    ''
FROM
    data
    JOIN tmp_name_map nm ON nm.id=data.id
WHERE
   feat_id IS NOT NULL AND 
   (
	rev_treaty_date != '' or
	rev_treaty_page != '' or
	rev_treaty_legislation != ''
    )
    and rev_treaty_legislation ~ E'\\s\\d{4}$';

-- select * from tmp_name_event where event_type='TSLR'

-- Apply changes defined in data_name_merge table.

ANALYZE tmp_name_event;

DROP TABLE IF EXISTS tmp_replacing_events;

CREATE TEMP TABLE tmp_replacing_events AS
SELECT
    distinct
    nmr.name_id as name_id_r,
    nms.name_id as name_id_s,
    nes.id as event_id,
    nm.status
FROM
    data_merge_replace dm
    join tmp_name_map nmr on dm.id1=nmr.id
    join tmp_name nm on nm.id = nmr.name_id
    left outer join tmp_name_event ner on ner.name_id = nmr.name_id
        and ner.event_type IN ('NZGZ','NZGH')
    join tmp_name_map nms on dm.id2=nms.id
    left outer join tmp_name_event nes on nes.name_id = nms.name_id
        and nes.event_type IN ('NZGZ','NZGH')
WHERE
    dm.action='R' and
    NOT exists (
        SELECT * 
        FROM tmp_name_event 
        WHERE 
            name_id=nmr.name_id AND
            event_type in ('NZGR','NZGS'));

-- Create a revoking event for the replaced names

DROP TABLE IF EXISTS tmp_replacing_events2;

CREATE TEMP TABLE tmp_replacing_events2 AS
SELECT 
    name_id_r,
    MIN(event_id) as event_id
FROM 
    tmp_replacing_events
WHERE
    event_id IS NOT NULL
GROUP BY
    name_id_r;

DELETE FROM error WHERE class='NEVT' and subclass='SPSR';
DELETE FROM error_class WHERE class='NEVT' and subclass='SPSR';

INSERT INTO error_class( class, subclass, description, info )
VALUES ('NEVT','SPSR','Creating revoking event defined in superceded spreadsheet', 'Y');
   
INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'SPSR',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Creating revoking event defined in superceded spreadsheet'
FROM
   data d
   JOIN tmp_replacing_events2 tr ON tr.name_id_r=d.id
   JOIN tmp_name_event ne ON ne.id = tr.event_id;
   
INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
SELECT
    tr.name_id_r,
    ne.event_date,
    CASE WHEN ne.event_type='NZGZ' THEN 'NZGR' ELSE 'NZGS' END,
    ne.authority,
    ne.event_reference,
    ''
FROM 
    tmp_replacing_events2 tr
    JOIN tmp_name_event ne ON ne.id = tr.event_id;

-- Create a revoking event for the replaced names
-- Reset the name status where applicable


DELETE FROM error WHERE class='NEVT' and subclass='SPSS';
DELETE FROM error_class WHERE class='NEVT' and subclass='SPSS';

INSERT INTO error_class( class, subclass, description, info )
VALUES ('NEVT','SPSS','Setting status to revoked for name defined in superceded spreadsheet', 'Y');
   
INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'SPSS',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Setting status to revoked for name defined in superceded spreadsheet'
FROM
   data d
   JOIN tmp_replacing_events t ON d.id = t.name_id_r
WHERE 
   t.status='OFAP';

UPDATE tmp_name
SET status='UORP'
WHERE id IN (
    SELECT name_id_r
    FROM tmp_replacing_events
    WHERE status='OFAP'
);
 
-- Finally add an event for recorded events with no other events...

INSERT INTO tmp_name_event
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes
)
SELECT
    tn.id,
    current_date,
    'RECN',
    'OFFD',
    'Section 4 NZGB Act 2008',
    'This recorded name was sourced from NZ Mainland Geographic Names (Topo, 1:50K)'
FROM
   tmp_name tn
   LEFT OUTER JOIN tmp_name_event ev ON ev.name_id = tn.id
WHERE
   tn.status = 'UREC' AND
   ev.name_id IS NULL;

-- 
    
DROP TABLE IF EXISTS tmp_replacing_events;
DROP TABLE IF EXISTS tmp_replacing_events2;

DELETE FROM error WHERE class='NEVT' and subclass='NEVT';
DELETE FROM error_class WHERE class='NEVT' and subclass='NEVT';

INSERT INTO error_class( class, subclass, description, info )
VALUES ('NEVT','NEVT','Unofficial name doesn''t have any events defined', 'Y');
   
INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'NEVT',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Unofficial name doesn''t have any events defined'
FROM
   data d
   JOIN tmp_name_map nm ON nm.id=d.id
   JOIN tmp_name tn ON tn.id=d.id
   LEFT OUTER JOIN tmp_name_event ev ON ev.name_id = d.id
WHERE
   d.feat_id IS NOT NULL AND 
   tn.status NOT LIKE 'O%' AND 
   tn.status <> 'STAT' AND 
   ev.name_id IS NULL;

DELETE FROM error WHERE class='NEVT' and subclass='NEVO';
DELETE FROM error_class WHERE class='NEVT' and subclass='NEVO';

INSERT INTO error_class( class, subclass, description)
VALUES ('NEVT','NEVO','Official name doesn''t have any events defined');
   
INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'NEVT',
   'NEVO',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Official name doesn''t have any events defined'
FROM
   data d
   JOIN tmp_name_map nm ON nm.id=d.id
   JOIN tmp_name tn ON tn.id=d.id
   LEFT OUTER JOIN tmp_name_event ev ON ev.name_id = d.id
WHERE
   d.feat_id IS NOT NULL AND 
   (tn.status LIKE 'O%' OR tn.status = 'STAT') AND 
   ev.name_id IS NULL;
   
   
-- SELECT * FROM error WHERE class='NEVT' AND subclass='NEVT'
-- SELECT COUNT(*) FROM tmp_name_event


ANALYZE tmp_name_event;

-- SELECT subclass, count(*) FROM error WHERE class = 'NEVT' group by subclass
