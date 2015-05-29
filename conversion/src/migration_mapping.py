# Script to extract the gazetteer data from the source migration spreadsheets
# into the gazetteer import tables.

import re
import sys
import database


db=database.db()
dbc = db.cursor()
dbc.execute('set role=gazetteer_admin')
dbc.execute('set search_path=gazetteer_import, gazetteer, public')

mapping = {}
with open("migration_mapping.txt") as mmf:
    for mml in mmf:
        parts=mml.split()
        col=parts[0]
        mapping[col] = parts[1:]

dbc.execute('select distinct src from data order by src')
srclist = [r[0] for r in dbc.fetchall()]
dbc.execute("select attname from pg_attribute where attrelid='gazetteer_import.data'::regclass and attnum > 5 order by attnum")
cols = [r[0] for r in dbc.fetchall()]

dbc.execute("select src, description from gazetteer_import.data_source")
srcdesc = {r[0]:r[1] for r in dbc.fetchall()}

dbc.execute("select code, value from gazetteer.system_code where code_group='NEVT'")
scnevt = {r[0]:r[1] for r in dbc.fetchall()}

dbc.execute("select code, value from gazetteer.system_code where code_group='NANT'")
scnant = {r[0]:r[1] for r in dbc.fetchall()}

dbc.execute("select code, value from gazetteer.system_code where code_group='FANT'")
scfant = {r[0]:r[1] for r in dbc.fetchall()}

def counts( where ):
    c = {}
    sql = 'select src, count(*) from data'
    if where:
        sql = sql + ' where ' + where
    sql = sql + ' group by src'
    dbc.execute(sql)
    for r in dbc.fetchall():
        c[r[0]]=r[1]
    return c

src_counts=[['total',counts('')]]
for c in cols:
    where = 'coalesce(' + '"'+c+'"' + "::varchar,'') <> ''"
    src_counts.append([c,counts(where)])

print "<html>"
print "<head>"
print "<title>Migration mapping</title>"
print "<style>"
print "body { font-family: verdana, helvetica, arial, sans }"
print "span.attrib { font-style: italic }"
print "span.event { color: #BB0000 }"
print "span.annot { color: #0000BB }"
print "span.fannot { color: #009999 }"
print "span.unmapped { background-color: #FFFF00; color: #880000 }"
print "td { vertical-align: top }"
print "td { border-bottom: solid 1px #CCCCCC }"
print "</style>"
print "</head>"
print "<body><h1>Migration mapping</h1>"
print "<p>The following table lists the fields in each spreadsheet, and which"
print '<span class="attrib">attribute</span>, '
print '<span class="event">event</span>, '
print '<span class="annot">name annotation</span> or '
print '<span class="fannot">feature annotation</span> '
print 'it maps to.</p>'
print "<table>"
print "<tr>"
print "<td>field</td>"
for col in srclist:
   print "<td>"+col+"</td>"
print "</tr>"
for field, counts in src_counts:
    print "<tr>"
    print "<td>"+field+"</td>"
    for col in srclist:
        count = counts.get(col,0)
        xls = srcdesc.get(col,col)

        print '<td title="'+xls+": "+field+'">'
        if count > 0:
            print str(count)
            dmap = mapping.get(field)
            mapped = False
            if dmap:
                for dest in dmap:
                    if '/' in dest:
                        (dest,dsht) = dest.split('/',2)
                        dsht = dsht[:-1] if dsht.endswith('*') else dsht
                        if col[:len(dsht)] != dsht:
                            continue
                    print "<br />"
                    dcls = 'attrib'
                    sc = None
                    if dest.startswith('@'):
                        sc=scnant
                        dest=dest[1:]
                        dcls='annot'
                    if dest.startswith('%'):
                        sc=scfant
                        dest=dest[1:]
                        dcls='fannot'
                    elif dest.startswith('*'):
                        sc=scnevt
                        dest=dest[1:]
                        dcls='event'
                    if dcls:
                        title = ''
                        if sc:
                            title = sc.get(dest,'')
                        if title:
                            title = ' title="'+title+'"'
                        print '<span class="'+dcls+'"'+title+'>'
                    print dest
                    mapped=True
                    if dcls:
                        print '</span>'

            if not mapped and field != 'total':
                print "<br /><span class=\"unmapped\">none</span>"
            print "</td>"
        else:
            print "-"
        print "</td>"
print "</table>"
print "</body>"
print "</html>"


