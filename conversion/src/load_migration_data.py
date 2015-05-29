# Script to extract the gazetteer data from the source migration spreadsheets
# into the gazetteer import tables.

import re
import sys
import xlrd
import database
from sheets import sheets

srcroot="../data/";
src=srcroot+"xls/current/"

# Sheet name: code: official names

base_cols = [
    'Official Name:name:varchar(100)',
    'Name:name:varchar(100)',
    'Name Status:status',
    'ID:feat_id_src:int',
    'Feature Type:feat_type:varchar(50)',
    'NZGB Gazette Reference:nzgb_ref:varchar(50)',
    'NZGB Gazette Date:nzgb_date:varchar(30)',
    'NZGB Gazette Number:nzgb_no:varchar(10)',
    'NZGB Gazette Page:nzgb_page:int',
    'Land District:district:varchar(50)',
    'Map Series:map_series:varchar(150)', # One long antarctic name
    'Map Sheet:map_sheet',
    'Grid Ref or Coodinate:map_ref:varchar(150)',
    'Grid Ref or Coordinate:map_ref:varchar(150)',
    'Projection:crd_projection:varchar(100)',
    'Northing:crd_north:float',
    'Easting:crd_east:float',
    'Datum:crd_datum:varchar(20)',
    'Latitude:crd_latitude:varchar(200)',
    'Longitude:crd_longitude:varchar(200)',
    'Reference Information:info_ref',
    'History/Origin/Meaning:info_origin',
    'Description:info_description',
    'Note:info_note',
    'Update By:update_by:varchar(50)',
    'Update Date:update_date:varchar(30)',
    'GIS Point:gis_point:bool',
    'GIS Line/Poly:gis_feat:bool',
    'GIS Line/Polygon:gis_feat:bool',
    'Geometry Type:geom_type',
    'Accuracy:accuracy:varchar(20)',
    'Accuracy Rating:accuracy_rating:int',
    'CPA Legislation:cpa_legislation',
    'CPA Legislation Section:cpa_section',
    'Conservancy:conservancy',
    'Description Code:desc_code:varchar(10)',
    'DoC Consunit Number:doc_cons_unit_no',
    'DoC Gazette Date:doc_gaz_date:varchar(30)',
    'DoC Gazette Number:doc_gaz_no:int',
    'DoC Gazette Page:doc_gaz_page:int',
    'DoC Gazette Reference:doc_gaz_ref:varchar(30)',
    'Duplication:duplication:int',
    'Edition Appears On:edition:varchar(100)',
    'GEBCO:gebco:bool',
    'Region:region:varchar(10)',
    'Revoke Gazette Date:rev_gaz_date:varchar(50)',
    'Revoke Gazette Number:rev_gaz_no:varchar(10)',
    'Revoke Gazette Page:rev_gaz_page:int',
    'Revoke Gazette Reference:rev_gaz_ref:varchar(30)',
    'Revoke Treaty Legislation Date:rev_treaty_date:varchar(30)',
    'Revoke Treaty Legislation Page:rev_treaty_page:varchar(30)',
    'Revoke Treaty Settlement Legislation:rev_treaty_legislation',
    'SCUFN:scufn:varchar(50)',
    'Treaty Legislation Date:treaty_date:varchar(30)',
    'Treaty Legislation Page:treaty_page:varchar(40)',
    'Treaty Settlement Legislation:treaty_legislation:varchar(150)',
    'Usea Id:usea_id',
    'Statutory Legislation:stat_legislation',
    'Statutory Legislation Date:stat_leg_date',
    'Statutory Legislation Page:stat_leg_page',
    'Height:height',
    'Antarctic Place Names Committee Reference:ant_pn_ref',
    'Antarctic Provisional Gazetteer Reference:ant_pgaz_ref',
    'Shown on Map:isonmap',
    'NZ 250000 Map:ant_nz250000_map',
    'US 250000 Map:ant_us250000_map',
    '50000 Map:ant_50000_map',
    'SCAR ID:scar_id',
    'Recorded in Scar by:scar_rec_by',
    'LAMPS PNT Description Code:ant_lamps_code',
    'Char\'s notes:ant_info_notes',
    'Moved in LAMPS:is_moved_in_lamps',
    'name/coord updates:ant_updates',
    'SCAR description (if missing or different):scar_desc',
    'Checked: ischecked',
    'Gazettal or Legislation:cpa_gazettal',
    ]

wsclean_fields=[
   'name',
    'status',
    'feat_id_src',
    'feat_type',
    'nzgb_ref',
    'nzgb_date',
    'nzgb_no',
    'nzgb_page',
    'district',
    'map_series',
    'map_sheet',
    'map_ref',
    'map_ref',
    'crd_projection',
    'crd_north',
    'crd_east',
    'crd_datum',
    'crd_latitude',
    'crd_longitude',
    'update_by',
    'update_date',
    'gis_point',
    'gis_feat',
    'gis_feat',
    'geom_type',
    'accuracy',
    'accuracy_rating',
    'cpa_legislation',
    'cpa_section',
    'conservancy',
    'desc_code',
    'doc_cons_unit_no',
    'doc_gaz_date',
    'doc_gaz_no',
    'doc_gaz_page',
    'doc_gaz_ref',
    'duplication',
    'edition',
    'gebco',
    'region',
    'rev_gaz_date',
    'rev_gaz_no',
    'rev_gaz_page',
    'rev_gaz_ref',
    'rev_treaty_date',
    'rev_treaty_page',
    'rev_treaty_legislation',
    'scufn',
    'treaty_date',
    'treaty_page',
    'treaty_legislation',
    'usea_id',
    ]

db = database.db()
dbc = db.cursor()
dbc.execute('set role=gazetteer_admin')
dbc.execute('set search_path=gazetteer_import, gazetteer, public')
dbc.execute('drop table if exists data')
dbc.execute(r"delete from data_source where src !~ E'AG\d\d'")
db.commit()        

# Load the status mapping spreadsheet

db.commit()        

colmap = {}
coltype = {}
cols = []
usedcols = {}

tabledef = 'create table data( id serial not null primary key, feat_id int, src char(4), lineno int'

# Redirect the output to a log file
log = open('load_migration_data.log','w')
stdout = sys.stdout
sys.stdout = log

for c in base_cols:
    (name,field,ftype) = (c+'::').split(':')[0:3]
    ftype = ftype or 'text'
    if field not in cols:
        tabledef += ', '+field+' '+ftype
        cols.append(field)
    colmap[name.lower()] = field
    coltype[name.lower()] = ftype

tabledef += ')'

dbc.execute(tabledef)
db.commit()

sheetno = 0
for s in sheets:
    sheetparts = s.split(':')
    sheetname, sheetcode = sheetparts[0:2]
    official = len(sheetparts) > 2
    description = re.sub(r'(?i)\.xls$','',sheetname)
    sheetno += 1
    dbc.execute("insert into data_source(src,is_official,priority,description) values (%s,%s,%s,%s)",(sheetcode,official,sheetno,description))

    stdout.write("Importing: "+sheetname+"\n")
    print "\nImporting: ",sheetname
    xl = xlrd.open_workbook(src+sheetname)
    sheet = xl.sheet_by_index(0)
    datemode = xl.datemode
    
    header = [c for c in sheet.row(0)]
    impcols = []
    imptypes = []
    impfields = []
    namecol = -1
    idcol = -1
    sql='insert into data( src, lineno'
    sqlvars = '%s, %s'
    for i,c in enumerate(sheet.row(0)):
        colname = str(c.value).lower().strip().replace(':','')
        col = colmap.get(colname)
        if col:
            usedcols[colname] = 1
            if col == 'name':
                namecol = i
            if col == 'feat_id_src':
                idcol = i
            impcols.append(i)
            imptypes.append(coltype[colname])
            impfields.append(col)
            sql += ', '+col
            sqlvars += ', %s'
            # print "Col ",i," (",c.value,"): ",col," - ",coltype[colname]
        elif c.value:
            print "Unused column: ",c.value
    sql += ') VALUES (' + sqlvars + ')'

    if namecol < 0:
        print "name column not defined in spreadsheet"
        continue

    if idcol < 0:
        print "feat_id column not defined in spreadsheet"
        continue

    cursor = dbc
    print "Loading",sheet.nrows,"rows"
    nblank = 0
    nerror = 0
    for r in range(1,sheet.nrows):
        row = sheet.row(r)
        if row[namecol].ctype in [0,6]:
            nblank += 1
            print "Blank name - row omitted: ",sheetname,": row ",r
            continue
        #if row[idcol].ctype in [0,6]:
        #    continue
        data = [sheetcode,r+1]
        for i in range(len(impcols)):
            value = None
            ftype = imptypes[i]
            field = impfields[i]
            try:
                c = row[impcols[i]]
                value = c.value
                if c.ctype in [0,6]:
                    value = None
                elif c.ctype == 1:
                    value = re.sub(r'^\s+','',re.sub('\s+$','',value))
                    value = re.sub(r'^(\d+)\.0$',r'\1',value)
                    value = None if value in ['','None','-'] else value
                elif c.ctype == 3:
                    date = xlrd.xldate_as_tuple(c.value,datemode)
                    value = "%04d-%02d-%02d" % date[0:3]
                if ftype == 'int' and value:
                    value = int(value)
                elif ftype == 'float' and value:
                    value = float(value)
                elif ftype == 'bool':
                    value = bool(value)
                elif ftype == 'date' and c.ctype == 2:
                    value = "%04d-01-01"%(value,)
                if (ftype == 'text' or ftype.startswith('varchar')) and value != None:
                    value=unicode(value).strip()
                    if c.ctype == 2 and value.endswith('.0'):
                        value = value[0:-2]
                    if field in wsclean_fields:
                        value = re.sub(r'\s+',' ',value)
                    if value == '':
                        value = None
            except:
                message = str(sys.exc_info()[1])
                print "Error: ",sheetname,": row ",r,": ",field,": ",message

            # Specific field fixes
            
            if field == 'map_sheet' and type(value) == unicode:
                if value in ['260','NZMS 260']:
                    value = 'NZMS260'
                if value in ['1','NZMS 1'] and type(value) == unicode:
                    value = 'NZMS1'

            if field == 'scufn' and type(value) == unicode:
                value = re.sub(r'(?i)^accredited(\s+by\:)?\s+','',value)

            data.append(value)

        try:
            cursor.execute(sql,data)
            db.commit()
        except:
            db.rollback()
            nerror+=1
            message = str(sys.exc_info()[1])
            print "SQL Error: ",sheetname,": row ",r,": ",message
            for d in data:
                print "|",unicode(d).encode('ascii','backslashreplace'),"|"


    if nblank > 0:
        print nblank," blank records"
        stdout.write("**** " +str(nblank) + " blank records\n")
    if nerror > 0:
        print nerror," error records"
        stdout.write("**** " +str(nerror) + " sql load errors\n")

dbc.execute('update data set feat_id=feat_id_src')
dbc.execute('create index data_fid on data( feat_id )')
dbc.execute('analyze data')
db.commit()

unused = []
for c in colmap.keys():
    if c not in usedcols:
        unused.append(c)
if unused:
    print "Unused columns:"
    for c in unused:
        print "   ",c
