# Script to extract the gazetteer data from the source migration spreadsheets
# into the gazetteer import tables.

import re
import sys
import xlrd
import database

srcroot="../data/";

db = database.db()
dbc = db.cursor()
dbc.execute('set role=gazetteer_admin')
dbc.execute('set search_path=gazetteer_import, gazetteer, public')
dbc.execute('drop table if exists data_merge_replace')
dbc.execute('''
            create table data_merge_replace( 
                merge_id serial not null primary key, 
                src1 char(4),
                lineno1 int,
                name1 text, 
                feat_id1 int,
                type1 varchar(50),
                nzgb_ref1 varchar(50),
                reference1 text,
                id1 int, 

                src2 char(4),
                lineno2 int,
                name2 text, 
                feat_id2 int,
                type2 varchar(50),
                nzgb_ref2 varchar(50),
                reference2 text,
                id2 int, 

                action char(1))
            ''')
db.commit()        

# Load the status mapping spreadsheet

reqcols='pair_id src lineno name feat_id type nzgb_ref reference action'.split()
colre = dict (
    pair_id= re.compile(r'^\d+$'),
    src= re.compile(r'^[A-Z0-9]+$'),
    lineno= re.compile(r'^\d+$'),
    action= re.compile(r'^[MDR]?$'),
    )

if True:
    sfile=srcroot+'superceded.xls'
    smw = xlrd.open_workbook(sfile)
    sheet = smw.sheet_by_index(0)
    cols = [str(c.value).lower().strip() for c in sheet.row(0)]
    cmap = {}
    colmax = 0
    valid = True
    for c in reqcols:
        if c not in cols:
            print "Column",c,"is missing in",sfile
            valid = False
            continue
        icol = cols.index(c)
        cmap[c] = icol
        colmax = max(icol,colmax)
    if not valid:
        sys.exit()

    def cv( cell ):
        if cell.ctype == xlrd.XL_CELL_NUMBER:
            return str(int(cell.value))
        else:
            return str(cell.value).strip()

    
    for r in range(1,sheet.nrows-1,2):
        row1 = sheet.row(r)
        row2 = sheet.row(r+1)
        data = [{},{}]
        valid=True
        for col,icol in cmap.items():
            v1=cv(row1[icol]) if icol < len(row1) else ''
            v2=cv(row2[icol]) if icol < len(row2) else ''
            if col in colre:
                if not colre[col].match(v1):
                    print "Invalid",col,"=",v1,"at row",r,"of",sfile
                    valid=False
                if not colre[col].match(v2):
                    print "Invalid",col,"=",v2,"at row",r,"of",sfile
                    valid=False
            data[0][col]=v1
            data[1][col]=v2

        if data[0]['pair_id'] != data[1]['pair_id']:
            print "Unmatched pair at row",r,"of",sfile
            valid=False
        if data[0]['action']=='D' and data[1]['action']=='D':
            continue
        if data[0]['action']=='' and data[1]['action']=='':
            continue
        if data[0]['action']=='R' and data[1]['action']=='':
            pass
        elif data[0]['action']=='' and data[1]['action']=='R':
            data.reverse()
        elif data[0]['action']=='M' and data[1]['action']=='M':
            pass
        else:
            print "Inconsistent actions",data[0]['action'],":",data[1]['action'],"at row",r,"of",sfile
            valid = False

        if valid:
            dbc.execute('''
                insert into data_merge_replace( 
                        src1, lineno1, name1, feat_id1, type1, nzgb_ref1, reference1,
                        src2, lineno2, name2, feat_id2, type2, nzgb_ref2, reference2,
                        action) 
                        values 
                        (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)''',
                       (
                        data[0]['src'],
                        data[0]['lineno'],
                        data[0]['name'],
                        data[0]['feat_id'],
                        data[0]['type'],
                        data[0]['nzgb_ref'],
                        data[0]['reference'],
                        data[1]['src'],
                        data[1]['lineno'],
                        data[1]['name'],
                        data[1]['feat_id'],
                        data[1]['type'],
                        data[1]['nzgb_ref'],
                        data[1]['reference'],
                        data[0]['action'])
                       )

db.commit()        
dbc.execute('create index idx_dmr_src1 on data_merge_replace(src1, lineno1)')
dbc.execute('create index idx_dmr_src2 on data_merge_replace(src2, lineno2)')
db.commit()


