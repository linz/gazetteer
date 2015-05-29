with t(class, subclass, errcount)  as
(
select class, subclass,count(*) from error group by class, subclass
)
select class, subclass,errcount, (select error from error e where e.class=t.class and e.subclass=t.subclass limit 1) as example
from t order by errcount desc;

select * from error;