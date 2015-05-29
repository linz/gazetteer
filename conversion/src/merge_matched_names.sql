
-- Script to apply feature merging based on matched names from the 
-- superceded spreadsheet in the data_merge_replace table.

set search_path=gazetteer_import, gazetteer, public;
set search_path=gazetteer_import, gazetteer, public;

-- Relink merge table

drop table if exists tmp_merge_1;

create temp table tmp_merge_1 as
select 
   merge_id,
   src1 as src,
   lineno1 as lineno,
   name1 as name,
   feat_id1 as feat_id,
   type1 as type,
   nzgb_ref1 as nzgb_ref,
   reference1 as reference,
   id1 as id
from
   data_merge_replace;

update tmp_merge_1 
set id = (
      select id from data 
      where 
      data.src = tmp_merge_1.src and
      data.lineno = tmp_merge_1.lineno and
      data.name = tmp_merge_1.name and
      data.feat_id = tmp_merge_1.feat_id
      )
    where id is NULL;

    -- select * from tmp_merge_1  

drop table if exists tmp_merge_2;

create temp table tmp_merge_2 as
select 
   t.merge_id,
   min(d.id) as data_id,
   count(d.id)
from 
   tmp_merge_1 t
   join data d on
   t.feat_id = d.feat_id and
   t.src = d.src and
   t.name = d.name and 
   t.type = d.feat_type
where
   t.id is NULL
group by
   t.merge_id
having 
   count(d.id) = 1;

update tmp_merge_1
set id = (select data_id from tmp_merge_2 where tmp_merge_2.merge_id=tmp_merge_1.merge_id)
where id is NULL;

drop table if exists tmp_merge_2;

create temp table tmp_merge_2 as
select 
   t.merge_id,
   min(d.id) as data_id,
   count(d.id)
from 
   tmp_merge_1 t
   join data d on
   t.feat_id = d.feat_id and
   t.src = d.src and
   t.name = d.name and 
   t.type = d.feat_type and
   coalesce(t.nzgb_ref,'') = coalesce(d.nzgb_ref,'') and
   coalesce(t.reference,'') = coalesce(d.info_ref,'') 
where
   t.id is NULL
group by
   t.merge_id
having 
   count(d.id) = 1;

update tmp_merge_1
set id = (select data_id from tmp_merge_2 where tmp_merge_2.merge_id=tmp_merge_1.merge_id)
where id is NULL;

update data_merge_replace 
set id1 = (select id from tmp_merge_1 where tmp_merge_1.merge_id=data_merge_replace.merge_id);

drop table if exists tmp_merge_1;

create temp table tmp_merge_1 as
select 
   merge_id,
   src2 as src,
   lineno2 as lineno,
   name2 as name,
   feat_id2 as feat_id,
   type2 as type,
   nzgb_ref2 as nzgb_ref,
   reference2 as reference,
   id2 as id
from
   data_merge_replace;

update tmp_merge_1 
set id = (
      select id from data 
      where 
      data.src = tmp_merge_1.src and
      data.lineno = tmp_merge_1.lineno and
      data.name = tmp_merge_1.name and
      data.feat_id = tmp_merge_1.feat_id
      )
    where id is NULL;

    -- select * from tmp_merge_1  

drop table if exists tmp_merge_2;

create temp table tmp_merge_2 as
select 
   t.merge_id,
   min(d.id) as data_id,
   count(d.id)
from 
   tmp_merge_1 t
   join data d on
   t.feat_id = d.feat_id and
   t.src = d.src and
   t.name = d.name and 
   t.type = d.feat_type
where
   t.id is NULL
group by
   t.merge_id
having 
   count(d.id) = 1;

update tmp_merge_1
set id = (select data_id from tmp_merge_2 where tmp_merge_2.merge_id=tmp_merge_1.merge_id)
where id is NULL;

drop table if exists tmp_merge_2;

create temp table tmp_merge_2 as
select 
   t.merge_id,
   min(d.id) as data_id,
   count(d.id)
from 
   tmp_merge_1 t
   join data d on
   t.feat_id = d.feat_id and
   t.src = d.src and
   t.name = d.name and 
   t.type = d.feat_type and
   coalesce(t.nzgb_ref,'') = coalesce(d.nzgb_ref,'') and
   coalesce(t.reference,'') = coalesce(d.info_ref,'') 
where
   t.id is NULL
group by
   t.merge_id
having 
   count(d.id) = 1;

update tmp_merge_1
set id = (select data_id from tmp_merge_2 where tmp_merge_2.merge_id=tmp_merge_1.merge_id)
where id is NULL;


update data_merge_replace 
set id2 = (select id from tmp_merge_1 where tmp_merge_1.merge_id=data_merge_replace.merge_id);

drop table tmp_merge_1;
drop table tmp_merge_2;

-- Report invalid data in merge table

DELETE FROM error WHERE class='NAME' and subclass='MRGX';
DELETE FROM error_class WHERE class='NAME' and subclass='MRGX';
   
INSERT INTO error_class( class, subclass, description, idtype, info )
VALUES ('NAME','MRGX','Unmatched record in data_merge_replace','NONE', 'Y');

INSERT INTO error( id, class, subclass, error )
SELECT 
   merge_id,
   'NAME',
   'MRGX',
   CASE WHEN id1 IS NULL THEN
      src1 || ': ' || lineno1::VARCHAR(20) || ': ' || name1  || ': '
   ELSE
       ''
   END  ||
   CASE WHEN id2 IS NULL THEN
      src2 || ': ' || lineno2::VARCHAR(20) || ': ' || name2  || ': '
   ELSE
       ''
   END  || 'Source/lineno/name not matched in data'
FROM
   data_merge_replace dm
WHERE
   id1 IS NULL OR
   id1 IS NULL;

-- select * from error where class='NAME' and subclass='MRGX';

-- Check that the data is consistent with the source data.

drop table if exists tmp_merged;

create temp table tmp_merged as 
select 
   dm.merge_id,
   greatest(d1.feat_id,d2.feat_id) as feat_id1,
   least(d1.feat_id,d2.feat_id) as feat_id2
from 
   data_merge_replace dm
   join data d1 on d1.id=dm.id1
   join data d2 on d2.id=dm.id2
where
   action in ('M','R');

    
-- select * from tmp_merged 
-- select * from data where feat_id_src != feat_id 

-- Recursive query to merge to minimum value...

DELETE FROM tmp_merged WHERE feat_id1=feat_id2;

create table tmp_merged2 as 
with recursive t1(feat_id1, feat_id2 ) as
(
   select 
       feat_id1,
       feat_id2
   from 
       tmp_merged
   union all
   select
       t1.feat_id1,
       tmp_merged.feat_id2
   from
       t1
       join tmp_merged on tmp_merged.feat_id1=t1.feat_id2
)  
select
   feat_id1,
   min(feat_id2) as feat_id2
from
   t1
group by
   feat_id1; 

update data
set feat_id = (select feat_id2 from tmp_merged2 where feat_id1=data.feat_id)
where feat_id in (select feat_id1 from tmp_merged2);



DELETE FROM error WHERE class='FEAT' and subclass='MRGU';
DELETE FROM error_class WHERE class='FEAT' and subclass='MRGU';

INSERT INTO error_class( class, subclass, description, idtype )
VALUES ('FEAT','MRGU','Info only: features merged from data_merge_replace table.','FEAT');

INSERT INTO error( id, class, subclass, error )
SELECT 
   tm.feat_id2,
   'FEAT',
   'MRGU',
   'Info only: Merging features ' || 
   array_to_string( array_agg(tm.feat_id1::varchar), ', ') ||
   ' into ' || tm.feat_id2::varchar
FROM
   tmp_merged2 tm
GROUP BY
   tm.feat_id2;

DROP TABLE tmp_merged;
DROP TABLE tmp_merged2;

-- select * from error where class='FEAT' and subclass='MRGU';
