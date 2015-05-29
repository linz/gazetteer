# Script to extract the gazetteer data from the source migration spreadsheets
# into the gazetteer import tables.

import re
import sys
import xlrd
import database
import unicodedata
from sheets import sheets
from collections import namedtuple

srcroot="../data/"
src=srcroot+"xls/current/"
smxls = src+".statusmapping - with processes.xls"

status_priority= '''
Approved
Assigned
Adopted
Validated
Altered
Recorded
Replaced
Current
Declined
Discontinued
'''.lower().split()


class codelist:

    def __init__( self ):
        self._codes = dict()

    def _normalize(self,name):
        name = ''.join(
                    x for x in unicodedata.normalize('NFKD', name) if 
                    unicodedata.category(x)[0] == 'L' or x == ' ').upper()
        # name = re.sub(r'\W',' ',name)
        name = ' '.join(name.split())
        return name


    def __call__( self, srcname, create=True, prefix='' ):
        name = self._normalize(srcname)
        if name in self._codes:
            return self._codes[name]
        if not create:
            return ''
        ncode = 4 - len(prefix)
        words = name.split()
        wmax = max(1,ncode-len(words)+1)
        wlen = [min(len(w),wmax) for w in words]
        wmax = max(wlen)
        nchar = 0
        while sum(wlen) > ncode:
            done = False
            for i in reversed(range(len(wlen))):
                if wlen[i] == wmax:
                    wlen[i] -= 1
                    done = True
                    break
            if done:
                continue
            wmax -= 1
            if wmax <= 0:
                break
        code=prefix
        for i in range(len(wlen)):
            code = code + words[i][:wlen[i]]
        code = (code + '0000')[0:4]
        if code in self._codes:
            for x in '0123456789ABCDEFGHIJKLMNOPARSTUVWXYZ':
                code = code[0:3]+x
                if code in self._codes:
                    break
        if code in self._codes:
            raise ValueError('Cannot generate code for '+name)
        self._codes[name]=code
        return code

# Sheet name: code: official names

db = database.db()
dbc = db.cursor()
dbc.execute('set role=gazetteer_admin')
dbc.execute('set search_path=gazetteer_import, gazetteer, public')
# Get the sheet codes

sheetcodes=set()
for s in sheets:
    sheet,code = s.split(':')[:2]
    sheetcodes.add(code)

# Load the status mapping spreadsheet

print "Loading status mappings from",smxls
smw = xlrd.open_workbook(smxls)
sheet = smw.sheet_by_index(0)

stage=''

Process = namedtuple('Process','code,name,description,statuses')
processes = {}
procodes = codelist()

Status = namedtuple('Status','code,status,official,nsto')
statuses = {}
statcodes = codelist()

Mapping=namedtuple('Mapping','code,name,srcstatus,pcode,scode')
mappings=[]
mapping_codes=set()

error = False

lastsheetcode=''
lastsheet=''
location = ''


try:
    for r in range(0,sheet.nrows):
        location = " - row "+str(r+1)
        row = sheet.row(r)
        nextstage = str(row[0].value).lower()
        if nextstage in ('processes','statuses','sheets'):
            stage=nextstage
            continue
    
        if not stage:
            continue
    
        if stage == 'processes':
            code, name, legislation = (unicode(row[r].value) for r in range(3))
            if name == 'name' or not name:
                continue
            code = procodes(name)
            if code in processes:
                print "Process",name,"is duplicated in spreadsheet",location
                error=True
                continue
            processes[code]=Process(code,name,legislation,set())
    
        if stage == 'statuses':
            code,process,status,official=(unicode(row[r].value) for r in range(4))
            if status=='status' or not status:
                continue
            if official not in ('Yes','No'):
                print "Status official code must be 'Yes' or 'No'",location
                error=True
            official = official=='Yes' 
            code = statcodes(status,prefix='O' if official else 'U')
            if code not in statuses:
                if status.lower() not in status_priority:
                    status_priority.append(status.lower())
                nsto = (('O' if official else 'U')+
                         '{0:02}'.format(status_priority.index(status.lower()))+
                         '0')
                statuses[code]=Status(code,status,official,nsto)
            else:
                if statuses[code].official != official:
                    print "Status '"+status+"' official status not consistent",location
                    error=True
            pcode = procodes(process,False)
            if not pcode:
                print "Status process '"+process+"' is not defined",location
                error=True
            else:
                processes[pcode].statuses.add(code)
    
        if stage == 'sheets':
            code,name,srcstatus,process,status=(unicode(row[r].value) for r in range(5))
            if srcstatus == 'srcstatus' or not srcstatus:
                continue
            if not code: code=lastsheetcode
            lastsheetcode = code
            if not name: name=lastsheet
            lastsheet = name
            pcode = procodes(process,False)
            skip=False
            if code not in sheetcodes:
                print "Sheet code '"+code+"' is not defined",location
                error=True
                skip=True
            if not pcode:
                print "Sheet process '"+process+"' is not defined",location
                error=True
                skip=True
            scode=statcodes(status,False)
            if not scode:
                print "Sheet status '"+status+"' is not defined",location
                error=True
                skip=True
            
            mapid=code+':'+srcstatus
            if mapid in mapping_codes:
                print "Mapping of",code,"-",srcstatus," is duplicated",location
                error=True
                skip=True
            else:
                mapping_codes.add(mapid)

            if not skip:
                mappings.append(Mapping(code,name,srcstatus,pcode,scode))
except:
    print "Error:",sys.exc_info()[1],location
    raise

'''
for p in [processes[k] for k in sorted(processes.keys())]:
    print p
for s in [statuses[k] for k in sorted(statuses.keys())]:
    print s
for m in mappings:
    print m
'''

if error:
    sys.exit()

#dbc.execute('delete from status_mapping')
# Clear out existing system codes

dbc.execute("delete from system_code where code_group='NPRO'");
dbc.execute("delete from system_code where code_group='NPST'");
dbc.execute("delete from system_code where code_group='NSTS' and code not in ('UNEW','UDEL')");
dbc.execute("delete from system_code where code_group='NSTO'");

db.commit()        

for p in [processes[k] for k in sorted(processes.keys())]:
    dbc.execute('insert into system_code( code_group, code, value, description ) values (%s, %s, %s, %s)',
                ('NPRO',p.code,p.name,p.description))
    dbc.execute('insert into system_code( code_group, code, value, description ) values (%s, %s, %s, %s)',
                ('NPST',p.code,' '.join(p.statuses),'Valid statuses for process '+p.name))
db.commit()

for s in [statuses[k] for k in sorted(statuses.keys())]:
    category = 'OFFC' if s.official else 'UOFC'
    dbc.execute('insert into system_code( code_group, code, category,value, description ) values (%s, %s, %s, %s, %s)',
                ('NSTS',s.code,category,s.status,s.status))
    dbc.execute('insert into system_code( code_group, code, category,value, description ) values (%s, %s, %s, %s, %s)',
                ('NSTO',s.code,None,s.nsto,s.status + ' priority'))
db.commit()

dbc.execute('delete from status_mapping')
db.commit()

for m in mappings:
    dbc.execute('insert into status_mapping(src,status,name_process,name_status) values (%s,%s,%s,%s)',
                (m.code,m.srcstatus,m.pcode,m.scode))
db.commit()

