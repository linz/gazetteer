--select count(*) from data;

-- select value from system_code where code_group='FTYP';

with t( feat_type) as
(
select distinct(feat_type) from data
)
select feat_type from t where feat_type not in
  (select value from system_code where code_group='FTYP')
  and feat_type not in
  (select value || 's' from system_code where code_group='FTYP')
  order by feat_type

