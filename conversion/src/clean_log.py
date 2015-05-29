import sys
import re

skip_lines = (
    
    'ALTER\s+(TABLE|SEQUENCE)',
    'ANALYZE',
    'CREATE\s+(FUNCTION|INDEX|SCHEMA|TABLE|VIEW)',
    r'DELETE\s+\d+',
    r'DETAIL\:\s+drop\s+.*',
    'DROP\s+(FUNCTION|SCHEMA|TABLE|VIEW)',
    'GRANT',
    r'INSERT\s+\d+\s+\d+',
    r'NOTICE\:\s+drop\s+.*',
    r'SELECT\s+\d+',
    'SELECT',
    'SET',
    r'TRUNCATE\s+TABLE',
    r'UPDATE\s+\d+',
    r'drop\s+cascades\s+to.*',
    r'psql\:.*\s+NOTICE\:\s+.*',
    'WARNING\s+\*\*\*.*produces\s+constant\s+result',
)

if len(sys.argv) != 2:
    print "Require log file name as argument\n"
    sys.exit()

filterre = '^(' + '|'.join(skip_lines) + ')'
filterre = re.compile(filterre)
logfile = sys.argv[1]
f = open(logfile,"rb")
lines = filter(lambda x: filterre.match(x) == None, f.readlines())
f.close()
f = open(logfile,"wb")
f.writelines(lines) 
f.close()
