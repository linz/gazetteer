-- Load the processed migration data from the import tables into the 
-- gazetteer schema..

set search_path=gazetteer, gazetteer_import, public;
set search_path=gazetteer, gazetteer_import, public;

SET client_min_messages=WARNING;

-- Create a table tmp_sql with sql to drop foreign table constraints, 
-- disable triggers, and to restore them, and a procedure tmp_run_sql
-- to apply these changes

DROP TABLE IF EXISTS tmp_sql;
CREATE TEMP TABLE tmp_sql AS
WITH tab(oid,name) AS
(
SELECT 
    cl.oid,
    ns.nspname || '.' || cl.relname
FROM 
    pg_class cl 
    JOIN pg_namespace ns ON cl.relnamespace = ns.oid
WHERE
    ns.nspname in ('gazetteer','gazetteer_history') AND
    cl.relkind='r'
),
seq(name) AS
(
    SELECT
       ns.nspname || '.' || cl.relname
    FROM 
       pg_class cl
      JOIN pg_namespace ns ON cl.relnamespace = ns.oid
    WHERE
       ns.nspname in ('gazetteer','gazetteer_history') AND
       cl.relkind='S'
)
SELECT 
    1 AS priority,
    'ALTER TABLE ' || tab.name || ' DROP CONSTRAINT ' || cn.conname as dropsql,
    'ALTER TABLE ' || tab.name || ' ADD CONSTRAINT ' || 
    cn.conname || ' ' || pg_get_constraintdef(cn.oid) as restoresql
FROM 
    pg_constraint cn 
    JOIN tab ON cn.conrelid=tab.oid
WHERE
    cn.contype='f'
UNION
SELECT 
    2 AS priority,
    'ALTER TABLE ' || tab.name || ' DISABLE TRIGGER ALL' as dropsql,
    'ALTER TABLE ' || tab.name || ' ENABLE TRIGGER ALL' as restoresql
FROM 
    tab
WHERE
    tab.name not like '%history%'
UNION
SELECT 
    3 AS priority,
    'TRUNCATE TABLE ' || tab.name as dropsql,
    NULL as restoresql
FROM 
    tab
WHERE
    name NOT LIKE 'gazetteer.system_code'
UNION
SELECT 
    4 AS priority,
    'ALTER SEQUENCE ' || name || ' RESTART WITH 1' as dropsql,
    NULL as restoresql
FROM 
    seq;

-- select dropsql from tmp_sql where dropsql is not null order by priority, dropsql
-- select restoresql from tmp_sql where restoresql is not null order by priority, restoresql

CREATE OR REPLACE FUNCTION tmp_run_sql( p_colname name )
RETURNS INT
AS
$body$
DECLARE
  v_sql RECORD;
BEGIN
  FOR v_sql IN 
    EXECUTE 'SELECT ' || p_colname || ' AS sql FROM tmp_sql ' || 
            'WHERE ' || p_colname || ' IS NOT NULL ORDER BY priority' LOOP
      EXECUTE v_sql.sql;
  END LOOP;
  RETURN 1;
END
$body$
LANGUAGE plpgsql;

SELECT tmp_run_sql( 'dropsql' );

-- Identify features and names that will not be imported

DELETE FROM error WHERE class='FEAT' and subclass='NONM';
DELETE FROM error_class WHERE class='FEAT' and subclass='NONM';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FEAT','NONM','Feature not imported as no valid name', 'FEAT');

DELETE FROM error WHERE class='FEAT' AND subclass='NONM';

INSERT INTO error( id, class, subclass, error )
SELECT 
   fd.feat_id,
   'FEAT',
   'NONM',
   fd.feat_id::VARCHAR(20) || ': Feature not imported as no valid name'
FROM
   tmp_feat_desc fd 
   join tmp_feat_type ft on ft.feat_id = fd.feat_id
   left outer join tmp_name on tmp_name.feat_id=fd.feat_id
WHERE
   tmp_name.feat_id is NULL;
 
-- Import feature shapes ...



insert into gazetteer.feature( 
    feat_id, 
    feat_type, 
    status, 
    description,
    ref_point,
    updated_by,
    update_date
    )
select 
   fd.feat_id,
   ft.ftype_code,
   'CURR',
   fd.description,
   CASE WHEN g.geom IS NULL then st_SetSRID(st_Point(170,-40),4167) ELSE g.geom END,
   'migration',
   current_timestamp
from
   tmp_feat_desc fd 
   join tmp_feat_type ft on ft.feat_id = fd.feat_id
   left outer join tmp_feat_point g on g.feat_id = fd.feat_id
where
   fd.feat_id in (select feat_id from tmp_name);

analyze gazetteer.feature;

insert into gazetteer.feature_geometry( 
   feat_id,
   geom_type,
   shape,
   updated_by,
   update_date
   )
select 
   feat_id, 
   'X',
   geom,
   'migration',
   current_timestamp
from 
   tmp_feat_geom
where
   feat_id in (select feat_id from gazetteer.feature) and 
   GeometryType(geom) = 'POINT';
 
insert into gazetteer.feature_geometry( 
   feat_id,
   geom_type,
   shape,
   updated_by,
   update_date
   )
select 
   feat_id, 
   'X',
   ST_GeometryN(geom,generate_series(1,ST_NumGeometries(geom))),
   'migration',
   current_timestamp
from 
   tmp_feat_geom
where
   feat_id in (select feat_id from gazetteer.feature) and 
  GeometryType(geom) = 'MULTIPOINT';

insert into gazetteer.feature_geometry( 
   feat_id,
   geom_type,
   shape,
   updated_by,
   update_date
   )
select 
   feat_id, 
   'L',
   geom,
   'migration',
   current_timestamp
from 
   tmp_feat_geom
where
   feat_id in (select feat_id from gazetteer.feature) and 
   GeometryType(geom) = 'LINESTRING';

insert into gazetteer.feature_geometry( 
   feat_id,
   geom_type,
   shape,
   updated_by,
   update_date
   )
select 
   feat_id, 
   'L',
   ST_GeometryN(geom,generate_series(1,ST_NumGeometries(geom))),
   'migration',
   current_timestamp
from 
   tmp_feat_geom
where
   feat_id in (select feat_id from gazetteer.feature) and 
   GeometryType(geom) = 'MULTILINESTRING';

insert into gazetteer.feature_geometry( 
   feat_id,
   geom_type,
   shape,
   updated_by,
   update_date
   )
select 
   feat_id, 
   'P',
   geom,
   'migration',
   current_timestamp
from 
   tmp_feat_geom
where
   feat_id in (select feat_id from gazetteer.feature) and 
   GeometryType(geom) = 'POLYGON';

insert into gazetteer.feature_geometry( 
   feat_id,
   geom_type,
   shape,
   updated_by,
   update_date
   )
select 
   feat_id, 
   'P',
   ST_GeometryN(geom,generate_series(1,ST_NumGeometries(geom))),
   'migration',
   current_timestamp
from 
   tmp_feat_geom
where
   feat_id in (select feat_id from gazetteer.feature) and 
   GeometryType(geom) = 'MULTIPOLYGON';

analyze gazetteer.feature_geometry;

-- Create mapping of source and status to name status/event

DELETE FROM error WHERE class='NAME' and subclass='NOFT';
DELETE FROM error_class WHERE class='NAME' and subclass='NOFT';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('NAME','NOFT','Name not imported as corresponding feature not imported', 'DATA');

DELETE FROM error WHERE class='FEAT' AND subclass='NOFT';

INSERT INTO error( id, class, subclass, error )
SELECT 
   tn.id,'NAME',
   'NOFT',
   tn.id::VARCHAR(20) || ': Name not imported as corresponding feature not imported'
FROM
   tmp_name tn
   left outer join feature f on tn.feat_id=f.feat_id
WHERE
   f.feat_id is NULL;

insert into gazetteer.name( 
   name_id, 
   feat_id,
   name,
   process,
   status,
   updated_by,
   update_date
   )
select
   id, 
   feat_id,
   name,
   process,
   status,
   'migration',
   current_timestamp
from
   tmp_name
where
   feat_id in (select feat_id from feature);

analyze gazetteer.name;

insert into gazetteer.name_annotation (
    name_id,
    annotation_type,
    annotation,
    updated_by,
    update_date
)
select
    name_id,
    annot_type,
    annotation,
    'migration',
    current_timestamp
from
    tmp_name_annot
where 
    name_id in (select name_id from name) and
    is_feat='N';

analyze gazetteer.name_annotation;

insert into gazetteer.feature_annotation (
    feat_id,
    annotation_type,
    annotation,
    updated_by,
    update_date
)
select
    distinct
    n.feat_id,
    a.annot_type,
    a.annotation,
    'migration',
    current_timestamp
from
    tmp_name_annot a 
    join name n on n.name_id = a.name_id
where 
    a.is_feat='Y';

insert into gazetteer.feature_annotation (
    feat_id,
    annotation_type,
    annotation,
    updated_by,
    update_date
)
select
    f.feat_id,
    'NPUB',
    'Feature location not defined in migrated data - arbitrary location used',
    'migration',
    current_timestamp
from
    gazetteer.feature f
    left outer join tmp_feat_point g on g.feat_id = f.feat_id
where
    g.feat_id IS NULL or not g.isreal;

analyze gazetteer.feature_annotation;


insert into gazetteer.name_event 
(
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes,
    updated_by,
    update_date
)
select
    name_id,
    event_date,
    event_type,
    authority,
    event_reference,
    notes,
    'migration',
    current_timestamp
from
    tmp_name_event
where
    name_id in (select name_id from name);

analyze gazetteer.name_event;

-- Record migration errors against each name

drop table if exists tmp_name_error;
create table tmp_name_error as
select
   e.error_id,
   e.id as name_id
from
   error e
   join error_class ec on ec.class=e.class and ec.subclass=e.subclass and ec.idtype='NAME'
where
   ec.info='N'
union
select
   e.error_id,
   m.name_id
from
   error e
   join error_class ec on ec.class=e.class and ec.subclass=e.subclass and ec.idtype='DATA'
   join tmp_name_map m ON m.id=e.id
where
   ec.info='N';

insert into gazetteer.name_annotation (
    name_id,
    annotation_type,
    annotation,
    updated_by,
    update_date
)
select
    ne.name_id,
    'MERR',
    e.class || ':' || e.subclass || ':' || e.error,
    'migration',
    current_timestamp
from
    tmp_name_error ne
    join error e on e.error_id=ne.error_id
where 
    ne.name_id in (select name_id from gazetteer.name);

drop table tmp_name_error;

insert into gazetteer.name_annotation (
    name_id,
    annotation_type,
    annotation,
    updated_by,
    update_date
)
select
    distinct
    na.name_id,
    'NPUB',
    'Official name with migration error',
    'migration',
    current_timestamp
from
    gazetteer.name_annotation na
    join gazetteer.name n on n.name_id=na.name_id
where
    na.annotation_type='MERR' and
    n.status in (
        select code from gazetteer.system_code 
        where code_group='NSTS' and category='OFFC'
        );

-- Record migration errors against each feature

drop table if exists tmp_feat_error;
create table tmp_feat_error as
select
   distinct
   e.error_id,
   e.id as feat_id
from
   error e
   join error_class ec on ec.class=e.class and ec.subclass=e.subclass and ec.idtype='FEAT'
where
   ec.info='N';

insert into gazetteer.feature_annotation (
    feat_id,
    annotation_type,
    annotation,
    updated_by,
    update_date
)
select
    ne.feat_id,
    'MERR',
    e.class || ':' || e.subclass || ':' || e.error,
    'migration',
    current_timestamp
from
    tmp_feat_error ne
    join error e on e.error_id=ne.error_id
where 
    ne.feat_id in (select feat_id from gazetteer.feature);

drop table tmp_feat_error;

insert into gazetteer.feature_annotation (
    feat_id,
    annotation_type,
    annotation,
    updated_by,
    update_date
)
select
    distinct
    na.feat_id,
    'NPUB',
    'Feature with migration error relates to official name',
    'migration',
    current_timestamp
from
    gazetteer.feature_annotation na
    join gazetteer.name n on n.feat_id=na.feat_id
where
    na.annotation_type='MERR' and
    n.status in (
        select code from gazetteer.system_code 
        where code_group='NSTS' and category='OFFC'
        );
-- Restore triggers and foreign key constraints

SELECT tmp_run_sql( 'restoresql' );
DROP FUNCTION tmp_run_sql(name);
DROP TABLE tmp_sql;

-- Reset sequences for columns explicitly set in SQL so that next
-- insertion generates a valid id.

CREATE OR REPLACE FUNCTION tmp_update_sequence( p_table varchar, p_col varchar )
RETURNS INT
AS
$body$
DECLARE
   v_sql text;
   v_next integer;
BEGIN
   EXECUTE 'SELECT MAX(' || p_col || ')+1 FROM ' || p_table  INTO v_next;
   EXECUTE 'ALTER SEQUENCE ' || p_table || '_' || p_col || '_seq RESTART WITH ' || v_next::varchar;
   RETURN v_next;
END
$body$
LANGUAGE plpgsql;

SELECT tmp_update_sequence( 'name', 'name_id');
SELECT tmp_update_sequence( 'feature', 'feat_id' );

DROP FUNCTION tmp_update_sequence( varchar, varchar );

SELECT count(*) as feature_count FROM feature;
SELECT count(*) as feature_annotation_count FROM feature_annotation;
SELECT count(*) as feature_association_count FROM feature_association;
SELECT count(*) as feature_geometry_count FROM feature_geometry;
SELECT count(*) as name_count FROM name;
SELECT count(*) as name_event_count FROM name_event;
SELECT count(*) as name_annotation_count FROM name_annotation;
SELECT count(*) as name_association_count FROM name_association;

SELECT count(*) as error_count 
FROM error e JOIN error_class ec on e.class=ec.class and e.subclass=ec.subclass and info='N';
