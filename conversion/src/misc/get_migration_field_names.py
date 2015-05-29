# Script based on load_migration_data.py to generate list 
# of field names in spreadsheets

import re
import sys
import xlrd
import csv

db_def=dict(
    host='localhost',
    database='<db>',
    user='<usr>',
    password='<pwd>',
    )

src="../../data/xls/"

# Sheet name: code: official names

sheets=[
    'New Zealand Official Names.xls:NZON:Y',
    '.Official Names 2010.xls:NYON:Y',
    'Railway Line Official Names.xls:RYON:Y',
    'Treaty Settlement Official Names.xls:TSON:Y',
    'Crown Protected Area Official Names.xls:CPON:Y',
    'Antarctic Official Names.xls:ANON:Y',
    'Offshore Island Official Names.xls:OION:Y',
    'Undersea Names.xls:USON:Y',

    'District Statutory Names.xls:DISN',
    'Recorded Names.xls:NZRN',
    'Antarctic Collected Names.xls:ANCN',
    'Offshore Island Recorded Names.xls:OIRN',
    
    'Removed-Replaced Names - NZ & Railway.xls:NZXN',
    'Removed-Replaced Names - CPA.xls:CPXN',
    'Removed-Replaced Names - Antarctic.xls:ANXN',
    ]

from collections import OrderedDict

sheetnames={}
cols=OrderedDict()
sheetno=0

for s in sheets:
    sheetparts = s.split(':')
    sheetname, sheetcode = sheetparts[0:2]
    official = len(sheetparts) > 2
    description = re.sub(r'(?i)\.xls$','',sheetname)
    sheetno += 1
    sheetnames[sheetno]=description

    print "\nImporting: ",sheetname
    xl = xlrd.open_workbook(src+sheetname)
    sheet = xl.sheet_by_index(0)
    datemode = xl.datemode
    
    for c in sheet.row(0):
         colname = str(c.value).lower().strip().replace(':','')
         if not colname:
             continue
         if colname not in cols:
             cols[colname]=[]
         cols[colname].append(sheetno)
         

with open('sheet_columns.csv','wb') as colcsv:
    w=csv.writer(colcsv)
    header=['column','notes']
    header.extend((sheetnames[i] for i in range(1,sheetno+1)))
    w.writerow(header)
    for c in cols:
       row = [c,'']
       onsheet=cols[c]
       row.extend(('' if s in onsheet else 'X' for s in range(1,sheetno+1)))
       w.writerow(row)

# 
#     impcols = []
#     imptypes = []
#     impfields = []
#     namecol = -1
#     idcol = -1
#     sql='insert into data( src, lineno'
#     sqlvars = '%s, %s'
#     for i,c in enumerate(sheet.row(0)):
#         colname = str(c.value).lower().strip().replace(':','')
#         col = colmap.get(colname)
#         if col:
#             usedcols[colname] = 1
#             if col == 'name':
#                 namecol = i
#             if col == 'feat_id':
#                 idcol = i
#             impcols.append(i)
#             imptypes.append(coltype[colname])
#             impfields.append(col)
#             sql += ', '+col
#             sqlvars += ', %s'
#             # print "Col ",i," (",c.value,"): ",col," - ",coltype[colname]
#         elif c.value:
#             print "Unused column: ",c.value
#     sql += ') VALUES (' + sqlvars + ')'
# 
#     if namecol < 0:
#         print "name column not defined in spreadsheet"
#         continue
# 
#     if idcol < 0:
#         print "feat_id column not defined in spreadsheet"
#         continue
# 
#     cursor = db.cursor()
#     for r in range(1,sheet.nrows):
#         row = sheet.row(r)
#         if row[namecol].ctype in [0,6]:
#             continue
#         if row[idcol].ctype in [0,6]:
#             continue
#         data = [sheetcode,r+1]
#         for i in range(len(impcols)):
#             value = None
#             ftype = imptypes[i]
#             field = impfields[i]
#             try:
#                 c = row[impcols[i]]
#                 value = c.value
#                 if c.ctype in [0,6]:
#                     value = None
#                 elif c.ctype == 1:
#                     value = re.sub(r'^\s+','',re.sub('\s+$','',value))
#                     value = re.sub(r'^(\d+)\.0$',r'\1',value)
#                     value = None if value in ['','None','-'] else value
#                 elif c.ctype == 3:
#                     date = xlrd.xldate_as_tuple(c.value,datemode)
#                     value = "%04d-%02d-%02d" % date[0:3]
#                 if ftype == 'int' and value:
#                     value = int(value)
#                 elif ftype == 'float' and value:
#                     value = float(value)
#                 elif ftype == 'bool':
#                     value = bool(value)
#                 elif ftype == 'date' and c.ctype == 2:
#                     value = "%04d-01-01"%(value,)
#                 if (ftype == 'text' or ftype.startswith('varchar')) and value != None:
#                     value=unicode(value).strip()
#                     if c.ctype == 2 and value.endswith('.0'):
#                         value = value[0:-2]
#                     if field in wsclean_fields:
#                         value = re.sub(r'\s+',' ',value)
#                     if value == '':
#                         value = None
#             except:
#                 message = str(sys.exc_info()[1])
#                 print "Error: ",sheetname,": row ",r,": ",field,": ",message
# 
#             # Specific field fixes
#             
#             if field == 'map_sheet' and type(value) == unicode:
#                 if value in ['260','NZMS 260']:
#                     value = 'NZMS260'
#                 if value in ['1','NZMS 1'] and type(value) == unicode:
#                     value = 'NZMS1'
# 
#             if field == 'scufn' and type(value) == unicode:
#                 value = re.sub(r'(?i)^accredited(\s+by\:)?\s+','',value)
# 
#             data.append(value)
# 
#         try:
#             cursor.execute(sql,data)
#             db.commit()
#         except:
#             db.rollback()
#             message = str(sys.exc_info()[1])
#             print "SQL Error: ",sheetname,": row ",r,": ",message
#             for d in data:
#                 print "|",unicode(d).encode('ascii','backslashreplace'),"|"
# 
# unused = []
# for c in colmap.keys():
#     if c not in usedcols:
#         unused.append(c)
# if unused:
#     print "Unused columns:"
#     for c in unused:
#         print "   ",c
