
-- Script to populate feature table from data imported by load_migration_data.py

SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET SEARCH_PATH TO gazetteer_import, gazetteer, public;
SET client_min_messages=WARNING;

-- Assign feature ids where missing

drop table if exists tmp_new_feat_id;

create temp table tmp_new_feat_id 
as
select id, 
   row_number() over (order by id) + 
   greatest( 
      (select max(feat_id) from gis),
      (select max(feat_id) from data)
      ) as feat_id
from data where feat_id is null;

update data 
set feat_id = (select feat_id from tmp_new_feat_id where id=data.id)
where feat_id is null;

-- Report features with no feature id

DELETE FROM error WHERE class='FEAT' AND subclass='NFID';
DELETE FROM error_class WHERE class='FEAT' AND subclass='NFID';

INSERT INTO error_class( class, subclass, description )
VALUES ('FEAT','NFID','Name has no feature id');

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.id,
   'FEAT',
   'NFID',
   d.src || ': ' || d.lineno::VARCHAR(20) 
         || ': Feature has no feature id - set to '
         || t.feat_id::varchar(20)
FROM
   data d
   join tmp_new_feat_id t on d.id = t.id
;

drop table tmp_new_feat_id;

-- ****************************************************************************
-- Compile the preferred feature description.  First choice is description with official 
-- name (NZON, TSON, RYON, OION, data source), then longest description.

drop table if exists tmp_feat_desc;

create table tmp_feat_desc( feat_id INT NOT NULL, description TEXT, rank INT );

DROP TABLE IF EXISTS tmp_desc1;
CREATE TEMP TABLE tmp_desc1 AS
SELECT 
   id,
   CASE WHEN src='DISN' THEN
       regexp_replace(info_description,E'\\..*','.')
    ELSE
       info_description
    END as fixed_description
   FROM data;
UPDATE tmp_desc1 SET fixed_description = NULL WHERE fixed_description = '';
-- select count(*) from tmp_desc1;
-- select src, info_description, fixed_description from data d join tmp_desc1 t on t.id=d.id where info_description <> fixed_description

INSERT INTO tmp_feat_desc 
select 
   feat_id,
   COALESCE(fixed_description, info_note, info_origin),
   row_number() over (
       partition by feat_id order by
       CASE 
          WHEN fixed_description IS NOT NULL THEN 0
          WHEN info_note IS NOT NULL THEN 1
          WHEN info_origin IS NOT NULL THEN 2
          ELSE 3
       END,
       CASE when src.is_official THEN 1 ELSE 0 END,
       src.priority,
       COALESCE(length(fixed_description), length(info_note), length(info_origin), 0) DESC)
from 
   data
   JOIN tmp_desc1 td ON td.id = data.id
   JOIN data_source src ON src.src = data.src
WHERE
   data.feat_id IS NOT NULL;

DROP TABLE tmp_desc1;

DELETE FROM tmp_feat_desc WHERE rank <> 1;

CREATE INDEX tfd_feat_id ON tmp_feat_desc( feat_id );

ANALYSE tmp_feat_desc;

DELETE FROM error WHERE class='FEAT' and subclass='NDSC';
DELETE FROM error_class WHERE class='FEAT' and subclass='NDSC';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FEAT','NDSC','Feature has no description', 'FEAT');

DELETE FROM error WHERE class='FEAT' AND subclass='NDSC';

INSERT INTO error( id, class, subclass, error )
SELECT 
   d.feat_id,
   'FEAT',
   'NDSC',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': Feature has no description'
FROM
   data d
   JOIN tmp_feat_desc t ON t.feat_id = d.feat_id
WHERE
   COALESCE(t.description,'') = '';
   
-- SELECT * FROM error WHERE class='FEAT' AND subclass='NDSC';
-- SELECT * FROM data WHERE feat_id IN (SELECT id FROM error WHERE class='FEAT' AND subclass='NDSC') ORDER BY feat_id; 

-- ****************************************************************************
-- Compile the feature type

DROP TABLE IF EXISTS tmp_src_fclass;
CREATE TEMP TABLE tmp_src_fclass( src VARCHAR(4), fclass VARCHAR(4));

INSERT INTO tmp_src_fclass
SELECT
   s.src,
   c.category
FROM
   (SELECT DISTINCT src FROM data WHERE src NOT LIKE 'CP%' AND src NOT LIKE 'US%') s,
   (SELECT DISTINCT category FROM system_code WHERE code_group='FTYP' AND category NOT IN ('CPAT','USEA')) c;

INSERT INTO tmp_src_fclass
SELECT
   DISTINCT
   s.src,
   'CPAT'
FROM
   data_source s
WHERE
   src LIKE 'CP%';

INSERT INTO tmp_src_fclass
SELECT
   DISTINCT
   s.src,
   'USEA'
FROM
   data_source s
WHERE
   src LIKE 'US%';

-- select * from tmp_src_fclass;

DROP TABLE IF EXISTS tmp_ftype_value;
CREATE TABLE tmp_ftype_value( value VARCHAR(100), code CHAR(4), fclass CHAR(4));

INSERT INTO tmp_ftype_value
SELECT 
   lower(gaz_plaintext(value)),
   code,
   category
FROM
   system_code
WHERE
   code_group = 'FTYP';

INSERT INTO tmp_ftype_value
SELECT
   lower(gaz_plaintext(value)) || 's',
   code,
   category
FROM
   system_code
WHERE
   code_group = 'FTYP' AND
   lower(value) || 's' NOT IN (SELECT lower(gaz_plaintext(value)) FROM system_code WHERE code_group='FTYP');

CREATE INDEX ftp_value ON tmp_ftype_value( fclass, value );

ANALYSE tmp_ftype_value;

-- select * from tmp_ftype_value;
-- select * from tmp_ftype_value where value in (select value from tmp_ftype_value f1 group by value having count(*) > 1) order by value

-- Normalise the feature type codes in the data

DROP TABLE IF EXISTS tmp_data_ftype;
CREATE TABLE tmp_data_ftype
(
   id INTEGER NOT NULL,
   feat_id INTEGER NOT NULL,
   src CHAR(4) NOT NULL,
   feat_type VARCHAR(50)
);

INSERT INTO tmp_data_ftype
SELECT
   id,
   feat_id,
   src,
   regexp_replace(lower(gaz_plaintext(feat_type)),E'\\s+feature$','')
FROM data
WHERE feat_id IS NOT NULL;

CREATE INDEX tdf_feat_id ON tmp_data_ftype( feat_id );

ANALYSE tmp_data_ftype;

-- select * from tmp_data_ftype

DROP TABLE IF EXISTS tmp_feat_type;
DROP TABLE IF EXISTS tmp_feat_type1;
DROP TABLE IF EXISTS tmp_feat_type2;

CREATE TABLE tmp_feat_type( feat_id INT NOT NULL, ftype_code CHAR(4));
CREATE TEMP TABLE tmp_feat_type1 (LIKE tmp_feat_type);
CREATE TEMP TABLE tmp_feat_type2 (LIKE tmp_feat_type);

CREATE INDEX ftp_fid ON tmp_feat_type2( feat_id );


-- Take values from official names in preference ..

INSERT INTO tmp_feat_type1
SELECT 
   distinct
   d.feat_id,
   c.code
FROM
   tmp_data_ftype d
   JOIN data_source src ON src.src = d.src
   JOIN tmp_src_fclass fc ON fc.src = d.src
   JOIN tmp_ftype_value c ON c.fclass = fc.fclass AND c.value = d.feat_type
WHERE
   src.is_official;

INSERT INTO tmp_feat_type2 SELECT * FROM tmp_feat_type1;
DELETE FROM tmp_feat_type1;
ANALYZE tmp_feat_type2;

-- Try aliases for offical sources (doesn't apply for CPA and undersea sources)

INSERT INTO tmp_feat_type1
SELECT 
   distinct
   d.feat_id,
   a.ftcode
FROM
   tmp_data_ftype d
   JOIN data_source src on src.src = d.src
   JOIN ftype_alias_code a ON a.alias = d.feat_type
   LEFT OUTER JOIN tmp_feat_type2 t ON t.feat_id=d.feat_id
WHERE
   src.is_official AND
   t.feat_id IS NULL AND
   d.src NOT LIKE 'CP%' AND
   d.src NOT LIKE 'US%';

INSERT INTO tmp_feat_type2 SELECT * FROM tmp_feat_type1;
DELETE FROM tmp_feat_type1;

ANALYSE tmp_feat_type2;

-- Try unofficial name sources

INSERT INTO tmp_feat_type1
SELECT 
   distinct
   d.feat_id,
   c.code
FROM
   tmp_data_ftype d
   JOIN tmp_src_fclass fc ON fc.src = d.src
   JOIN tmp_ftype_value c ON c.fclass = fc.fclass AND c.value = d.feat_type
   LEFT OUTER JOIN tmp_feat_type2 t ON t.feat_id=d.feat_id
WHERE
   t.feat_id IS NULL;

INSERT INTO tmp_feat_type2 SELECT * FROM tmp_feat_type1;
DELETE FROM tmp_feat_type1;
ANALYSE tmp_feat_type2;

-- Try aliases (doesn't apply for CPA and undersea sources)

INSERT INTO tmp_feat_type1
SELECT 
   distinct
   d.feat_id,
   a.ftcode
FROM
   tmp_data_ftype d
   JOIN ftype_alias_code a ON a.alias = d.feat_type
   LEFT OUTER JOIN tmp_feat_type2 t ON t.feat_id=d.feat_id
WHERE
   t.feat_id IS NULL AND
   d.src NOT LIKE 'CP%' AND
   d.src NOT LIKE 'US%';

INSERT INTO tmp_feat_type2 SELECT * FROM tmp_feat_type1;
DELETE FROM tmp_feat_type1;
ANALYSE tmp_feat_type2;

-- Unmatched feature types

INSERT INTO tmp_feat_type1
SELECT 
   distinct
   d.feat_id,
   'UNDF'
FROM
   tmp_data_ftype d
   LEFT OUTER JOIN tmp_feat_type2 t ON t.feat_id=d.feat_id
WHERE
   t.feat_id IS NULL;

INSERT INTO tmp_feat_type2 SELECT * FROM tmp_feat_type1;
DELETE FROM tmp_feat_type1;
DROP TABLE tmp_feat_type1;
ANALYSE tmp_feat_type2;

-- Feature type errors ...


DELETE FROM error WHERE class='FEAT' and subclass='AMBT';
DELETE FROM error_class WHERE class='FEAT' and subclass='AMBT';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FEAT','AMBT','Feature type is ambiguous/inconsistent', 'FEAT');

DELETE FROM error WHERE class='FEAT' and subclass='FTUN';
DELETE FROM error_class WHERE class='FEAT' and subclass='FTUN';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FEAT','FTUN','Feature type(s) in spreadsheet not recognized', 'FEAT');

DELETE FROM error WHERE class='FEAT' AND subclass IN ('AMBT', 'FTUN');

-- Ambiguous feature types - not resolved by above process..

INSERT INTO error( id, class, subclass, error )
SELECT
   distinct 
   d.feat_id,
   'FEAT',
   'AMBT',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || d.feat_type || ': Feature type ambiguous'
FROM
   data d
WHERE
   d.feat_id IN (SELECT feat_id FROM tmp_feat_type2 GROUP BY feat_id HAVING count(*) > 1);

-- Unassigned feature types
 
INSERT INTO error( id, class, subclass, error )
SELECT 
   d.feat_id,
   'FEAT',
   'FTUN',
   d.src || ': ' || d.lineno::VARCHAR(20) || ': ' || COALESCE(d.feat_type,'') || ': Feature type unrecognized'
FROM
   data d
WHERE
   d.feat_id IN (SELECT feat_id FROM tmp_feat_type2 WHERE ftype_code = 'UNDF');

DROP TABLE tmp_ftype_value;

-- Arbitrarily select one of potentially ambigous feature types

insert into tmp_feat_type( feat_id, ftype_code )
select feat_id, max(ftype_code) from tmp_feat_type2 group by feat_id;

CREATE INDEX ftp_fid ON tmp_feat_type( feat_id );

DROP TABLE tmp_feat_type2;
ANALYSE tmp_feat_type;

-- select * from error where class='FEAT' and subclass='AMBT' order by id;
-- select * from error where class='FEAT' and subclass='FTUN' order by id;
-- select * from error where subclass='DIFT' order by id;
-- select split_part( error, ': ', 1 ), split_part( error, ': ', 3 ), count(*) from error where subclass='FTUN' group by split_part( error, ': ', 1 ), split_part( error, ': ', 3 ) order by count(*) desc;

-- select * from tmp_ftype_value where fclass='USEA'

-- select
--    s.value,
--    count(*),
--    max(CASE WHEN 
--       f.feat_id IN (SELECT feat_id FROM data WHERE src IN ('NZON','TSON','RYON','OION'))
--       THEN '*' ELSE '' END)
-- from 
--    tmp_feat_type2 f 
--    join system_code s on s.code_group='FTYP' and s.code=f.ftype_code
-- where
--    s.category='UNCL'
--    --AND f.feat_id in (SELECT feat_id FROM data WHERE src IN ('NZON','TSON','RYON','OION'))
-- group by
--    s.value 
-- order by
--    count(*) DESC 

