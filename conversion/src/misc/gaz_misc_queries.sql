-- Set of queries ... not really useful 

set search_path=gazetteer, public;
select * from gaz_import limit 10;

select * from gaz_import where name is NULL or name = '';
delete from gaz_import where name in ('Antarctic Replaced/Removed Names','CPA Replaced/Removed Names');

select * from gaz_import where feat_type is null;
select * from gaz_import where feat_id in (select feat_id from gaz_import where feat_type is null) order by feat_id;

select * from gaz_import where feat_id is null;

-- update gaz_import set feat_type=NULL where feat_type = 'None';
select feat_type, count(*) from gaz_import group by feat_type order by feat_type;

-- update gaz_import set nzgb_date=NULL where nzgb_date='None';
-- update gaz_import set nzgb_date=replace(nzgb_date,'.0','') where nzgb_date ~ E'\\.0$';
select * from gaz_import where nzgb_date !~ '^\\d{4}\\-\\d\\d\\-\\d\\d$' and nzgb_date !~ '^(19|20)\\d\\d$'

-- update gaz_import set nzgb_no=replace(nzgb_no,'.0','') where nzgb_no ~ E'\\.0$';
select * from gaz_import where nzgb_no !~ '^\\d+$' and nzgb_no <> 'HON'
select * from gaz_import where nzgb_no = 'HON'
-- select * from gaz_import where district = 'NZGD2000';
-- delete from gaz_import where id=43597;
select district, count(*) from gaz_import group by district order by district;



update gaz_import set map_series='NZMS260' where map_series in ('260','NZMS 260');
update gaz_import set map_series='NZMS1' where map_series in ('1','NZMS 1');
update gaz_import set map_series=NULL where map_series in ('None','-');
--update gaz_import set map_series=trim(map_series);
select distinct(map_series)  from gaz_import where map_sheet ~ 'N\\d';
select map_series, count(*) from gaz_import group by map_series order by count(*) desc;

select distinct(map_sheet) from gaz_import;

select distinct(usea_id) from gaz_import where coalesce(usea_id,'') not in ('','None') and usea_id !~ '^\\d+$';

select map_ref, * from gaz_import
 where map_ref !~ '^\\d{7}(\\.\\d+)?E?\\,?\\s+\\d{7}(\\.\\d+)?N?$' and
       map_ref !~ '^\\d{6}$' and
       map_ref !~ '^X?(I|II|III|IV|V|VI|VII|VIII|IX|X)$';

-- Count of entries with and without nzgb_references
select src,nzgb_ref is null as have_nzgb_ref,count(*) from gaz_import group by src,nzgb_ref is null;

select src, status, count(*) from gaz_import group by src, status order by src, status;

select distinct status, nzgb_ref is NULL, rev_gaz_ref is NULL from gaz_import where src='RMRN' order by status;

select distinct status, case when nzgb_ref is NULL then 'null' else 'value' end, case when rev_gaz_ref is NULL then 'null' else 'value' end from gaz_import where src='RMRN' order by status;

select distinct src, duplication from gaz_import order by src, duplication;
select * from gaz_import where duplication=18;

select max(length(edition)) from gaz_import;
select distinct(treaty_legislation) from gaz_import;

select * from gaz_import where feat_id in 
(
select feat_id from gaz_import group by feat_id having count(distinct src) > 1
)
order by feat_id, src


  
select geom_type, count(*) from gaz_import group by geom_type;

select count(*) from gaz_import_gis;
select count(distinct feat_id) from gaz_import_gis;
select feat_id, St_GeometryType(geom),count(*) from gaz_import_gis group by feat_id, st_geometrytype(geom) having count(*) > 1

select count(*) from gaz_import where src in ('NZOF','RYON','NZRN','TSON')
select count(*) from gaz_import_gis where feat_id not in (select feat_id from gaz_import);

with c1 (src,c1) as 
(
select src, count(*) from gaz_import where feat_id not in (select feat_id from gaz_import_gis) group by src
), c2 (src, c2) as 
(
select src, count(*) from gaz_import group by src
)
select c2.src,c2.c2,c1.c1 from c2 left outer join c1 on c1.src = c2.src

select * from gaz_import where src in ('NZOF','RMRN') and feat_id not in (select feat_id from gaz_import_gis);

select distinct src, gis_point, gis_feat from gaz_import order by src, gis_point, gis_feat;

select feat_id,src,info_description from gaz_import 
where feat_id in (select feat_id from gaz_import group by feat_id having count(distinct info_description) > 1)
order by feat_id;

select distinct(region) from gaz_import
select * from gaz_import where region='NZ'
select distinct(accuracy) from gaz_import;
