################################################################################
#
# Copyright 2015 Crown copyright (c)
# Land Information New Zealand and the New Zealand Government.
# All rights reserved
#
# This program is released under the terms of the new BSD license. See the 
# LICENSE file for more information.
#
################################################################################


import sys
import getpass
import psycopg2
from osgeo import ogr

db_def=dict(
    host='',
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
