################################################################################
#
#  New Zealand Geographic Board gazetteer application,
#  Crown copyright (c) 2020, Land Information New Zealand on behalf of
#  the New Zealand Government.
#
#  This file is released under the MIT licence. See the LICENCE file found
#  in the top-level directory of this distribution for more information.
#
################################################################################

import re
import sys

import database

db = database.db()
dbc = db.cursor()
dbc.execute('set search_path=gazetteer_web, public')

def update_config_item( code, value, description="Description not available" ):
    vfield = 'intval' if type(value) == int else 'value'
    dbc.execute("select count(*) from gaz_web_config where code=%s",(code,))
    if dbc.fetchone()[0]:
        dbc.execute("update gaz_web_config set "+vfield+"=%s where code=%s",(value,code))
    else:
        dbc.execute("insert into gaz_web_config(code,description,"+vfield+") values (%s,%s,%s)",(code,description,value))
    db.commit()

try:
    with open('web_config/gazetteer_help.html') as hf:
        help = hf.read()

    m = re.search(r'\<body[^\>]*\>(.*)\<\/body\>',help,re.S)
    if m:
        print "Updating How To"
        content = m.group(1)
        update_config_item('HOWT',content,'"How to" content')
except:
    print sys.exc_info()[1]

try:
    with open('web_config/under_map.txt') as hf:
        content = hf.read().strip()
        if content:
            print "Updating under map text"
            update_config_item('FTRM',content,'Text displayed under the map')
except:
    print sys.exc_info()[1]
