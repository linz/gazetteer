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
import os.path
import codecs
import Database
from Model import SystemCode

class UnicodeWriter:
    """
    A CSV writer which will write rows to CSV file that avoid current 
    unicode issues with csv.writer
    """

    def __init__(self, f ):
        # Redirect output to a queue
        self.stream=f

    def encodefield( self, field ):
        if field == None:
            return ''
        field = unicode(field)  
        return ( '"'+field.replace('"','""')+'"'
                 if '"' in field or '\n' in field or ',' in field
                 else field)

    def writerow(self, row):
        self.stream.write(u','.join([self.encodefield(f) for f in row]))
        self.stream.write("\r\n");

class Export( object ):

    fields = None

    def __init__( self ):
        pass

    def csvExportTables( self ):
        for col in SystemCode.codeGroup('XDSN'):
            if col.category == 'CSVF':
                yield col.value

    def getTableCols( self, table ):
        sql = '''
        select 
           lower(attname)
        from 
           pg_attribute
        where 
           attrelid='{table}'::regclass
           and attnum > 0
        order by 
           attnum
        '''.replace('{table}',table)
        columns = [r[0] for r in Database.querysql(sql)]
        return columns

    def createCsvFile( self, table, filename ):
        fields = self.getTableCols(table)
        with codecs.open(filename,'wb','utf-8-sig') as f:
            csvfile = UnicodeWriter(f)

            sql = 'select ' + ','.join(['"'+f+'"' for f in fields]) + " from " + table
            if 'name' in fields:
                sql = sql + ' order by gazetteer.gaz_plaintext(name)'
            data = Database.querysql(sql)

            csvfile.writerow(fields)
            for row in Database.querysql(sql):
                csvfile.writerow(row)

            
    
    
    
            
       
