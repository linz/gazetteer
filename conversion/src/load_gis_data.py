# Import the gazetteer feature geometries from shape files into Postgis 
# import tables ready for processing by migration scripts

import os
import re
import sys
import database
from osgeo import ogr

shp_dir = '../data/gis/shp/current'

srid_map = {
    'NZGD_2000_New_Zealand_Transverse_Mercator':2193,
    'NZGD_2000_Antipodes_Islands_TM_2000':3790,
    'NZGD_2000_Auckland_Islands_TM_2000':3788,
    'NZGD_2000_Campbell_Island_TM_2000':3789,
    'NZGD_2000_Chatham_Islands_TM_2000':3793,
    'NZGD_2000_Raoul_Island_TM_2000':3791,
     }


db = database.db()
cursor = db.cursor()
cursor.execute('set role=gazetteer_admin')
cursor.execute('set search_path=gazetteer_import, gazetteer, public')
cursor.execute('select count(*) from data')
for r in cursor:
    if int(r[0]) == 0:
        print "Aborting GIS data load - no spreadsheet data"
        sys.exit()

cursor.execute('drop table if exists gis')
cursor.execute('''
    create table gis
    (
       id serial not null primary key,
       feat_id int,
       feat_id_src int,
       src char(4),
       srcno int,
       name varchar(100),
       srid int,
       geom geometry
    )
                    ''');
cursor.execute(r"delete from data_source where src ~ E'AG\d\d'")
db.commit();


shp_files = [f for f in os.listdir(shp_dir) if f.lower().endswith('.shp')]
print shp_files

nsrc=0
for shp in shp_files:
    print "Loading ",shp
    ds = ogr.Open(shp_dir+'/'+shp)
    layer = ds.GetLayer(0)
    defn = layer.GetLayerDefn()
    layername = defn.GetName()
    print "Layer: ",layername
    idfield = defn.GetFieldIndex('ID')
    if idfield < 0:
        print "Missing ID field"
        continue
    namfield = defn.GetFieldIndex('Official_N')
    if namfield < 0:
        print "Missing name field"
        continue
    nsrc += 1
    srccode='AG%02d' % (nsrc,)
    cursor.execute('insert into data_source(src,description) values (%s,%s)',(srccode,layername))
    nfeat = 0;

    while True:
        f = layer.GetNextFeature()
        if not f: break
        nfeat += 1
        id = f.GetFieldAsInteger(idfield)
        name = f.GetFieldAsString(namfield)
        geomref = f.GetGeometryRef()
        wkt =  geomref.ExportToWkt()
        sref = geomref.GetSpatialReference()
        sproj = sref.GetAttrValue("PROJCS") or sref.GetAttrValue("GEOGCS")
        srid=0
        if sproj in srid_map:
            srid = srid_map[sproj]
        if srid == 0:
            print "Cannot find srid for: ",sproj
            break
        cursor.execute('''
            insert into gis (feat_id_src, feat_id, src, srcno, name, srid, geom )
            values (%s,%s,%s,%s, %s,%s,ST_GeomFromText(%s))''',
            (id,id,srccode,nfeat,name,srid,wkt))
    db.commit()

db.cursor().execute('create index gis_fid on gis( feat_id )');
db.commit();


