import os
import re
import sys
import xlwt
import codecs
import database


db = database.db()
c=db.cursor()
c.execute('set search_path=gazetteer_import, gazetteer, public')
c.execute('update error set official=0')

outputxls='error_summary.xls'
if '-x' in sys.argv:
    i = sys.argv.index('-x')+1
    if i < len(sys.argv):
        outputxls = sys.argv[i]

c.execute('''
    update error
    set official=1
    where error_id in
    (
      select 
         e.error_id
      from 
         error e
         join error_class ec on ec.class=e.class and ec.subclass=e.subclass and ec.idtype='NAME'
         join name n on n.name_id = e.id
      where
         n.status in (
            select code
            from system_code
            where code_group = 'NSTS'
            and category='OFFC'
            )
    )
    ''')
    
c.execute('''
    update error
    set official=1
    where error_id in
    (
      select 
         e.error_id
      from 
         error e
         join error_class ec on ec.class=e.class and ec.subclass=e.subclass and ec.idtype='FEAT'
         join name n on n.feat_id = e.id
      where
         n.status in (
            select code
            from system_code
            where code_group = 'NSTS'
            and category='OFFC'
            )
    )       
    ''')
    
c.execute('''
    update error
    set official=1
    where error_id in
    (
      select 
         e.error_id
      from 
         error e
         join error_class ec on ec.class=e.class and ec.subclass=e.subclass and ec.idtype='DATA'
         join tmp_name_map m on m.id=e.id
         join name n on n.name_id = m.name_id
      where
         n.status in (
            select code
            from system_code
            where code_group = 'NSTS'
            and category='OFFC'
            )
    )    
    ''')

wb = xlwt.Workbook(encoding='utf8')
ws = wb.add_sheet('Data sources')
ws.write(0,0,'Code')
ws.write(0,1,'Source')

nr = 0
c.execute("select src,description from data_source order by case when src like 'AG%' then 1 else 0 end, src ")
for r in c:
    nr += 1
    ws.write(nr,0,r[0])
    ws.write(nr,1,r[1])

ws = wb.add_sheet('Error summary')
ws.write(0,0,'Class')
ws.write(0,1,'Subclass')
ws.write(0,2,'Count')
ws.write(0,3,'Official')
ws.write(0,4,'Example')

c.execute('''
with t(class, subclass, errcount,offcount)  as
(
select class, subclass,count(*),sum(official) from error group by class, subclass
)
select class, subclass,errcount, offcount,(select error from error e where e.class=t.class and e.subclass=t.subclass limit 1) as example
from t order by errcount desc;
          ''')
nr = 0
for r in c:
    nr += 1
    ws.write(nr,0,r[0])
    ws.write(nr,1,r[1])
    ws.write(nr,2,int(r[2]))
    ws.write(nr,3,int(r[3]))
    ws.write(nr,4,r[4])

ws=wb.add_sheet('Error details')
ws.write(0,0,'Class')
ws.write(0,1,'Subclass')
ws.write(0,2,'Id')
ws.write(0,3,'Search')
ws.write(0,4,'Official')
ws.write(0,5,'Error')

c.execute('''
select 
   e.class, 
   e.subclass, 
   e.id,
   case ec.idtype 
   when 'FEAT' then 'fid=' || e.id::varchar
   when 'NAME' then 'id=' || e.id::varchar
   when 'DATA' then 'id=' || (select name_id::varchar from tmp_name_map where id=e.id)
   else NULL end as search,
   e.official, 
   e.error 
from error e
   left outer join error_class ec on ec.class=e.class and ec.subclass=e.subclass
order by e.class, e.subclass, e.id
   ''')
nr = 0
for r in c:
    nr += 1
    if nr > 65530:
        print "More than 65530 errors!"
        break;
    ws.write(nr,0,r[0])
    ws.write(nr,1,r[1])
    ws.write(nr,2,int(r[2]))
    ws.write(nr,3,r[3])
    ws.write(nr,4,'Y' if int(r[4]) == 1 else 'N')
    ws.write(nr,5,r[5])

wb.save(outputxls)
