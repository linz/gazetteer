
import sys
import getpass
import psycopg2
from osgeo import ogr

db_def=dict(
    host='localhost',
    database='gazetteer',
    user=getpass.getuser(),
    password='',
    )

args = {'-h':'host', '-d':'database', '-U':'user', '-P':'password' }

i=0
while i < len(sys.argv)-1:
    if sys.argv[i] in args:
        db_def[args[sys.argv[i]]]=sys.argv[i+1]
        sys.argv[i:i+2] = []
    else:
        i += 1

def db(): 
    return psycopg2.connect(**db_def)
