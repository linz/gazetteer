import psycopg2
import getpass

_db = None
_autocommit = True
_restartRequired = False

_host = 'localhost'
_port = '5432'
_name = 'spi_db'
_user=getpass.getuser()
_password=''
_schema='gazetteer'
_searchSchema=[]

def host(): return _host
def setHost(host): 
    global _host; 
    if host != _host:
        _host=host
        _reset()

def port(): return _port
def setPort(port): 
    global _port; 
    if port != _port:
        _port=port 
        _reset()

def database(): return _name
def setDatabase(name): 
    global _name; 
    if _name != name:
        _name=name 
        _reset()

def user(): return _user
def setUser(user,password=None): 
    global _user, _password; 
    if user != _user or (password != None and password != _password):
        _user=user; 
        if password != None:
            setPassword(password)
        _reset()

def password(): return _password
def setPassword(password): 
    global _password; 
    if password != _password:
        _password=password 
        _reset()

def schema(): return _schema
def setSchema(schema): 
    global _schema; 
    if schema != _schema:
        _schema=schema; 
        _reset()

def searchSchema(): return _searchSchema
def setSearchSchema(searchSchema): 
    if _searchSchema != searchSchema:
        _searchSchema[:]=[]
        _searchSchema.extend(searchSchema)
        _reset()

def _reset():
    global _db
    global _restartRequired
    if _db:
        _restartRequired = True
        _db = None

def connection():
    global _db, _autocommit
    if _db == None:
        if _restartRequired:
            raise RuntimeError("You need to restart the application after changing database settings")
        db = psycopg2.connect(
            host=_host, 
            port=_port,
            database=_name, 
            user=_user, 
            password=_password
        )
        c = db.cursor()
        if 'public' not in _searchSchema:
            _searchSchema.append('public')
        search = ', '.join(_searchSchema);
        c.execute('set search_path='+_schema+', '+search )
        _db = db
        _autocommit = True
    return _db

def execute(  sql, *params ):
    global _db
    # Handle special case where sql is just a function name
    if ' ' not in sql:
        sql = 'select ' + sql + '(' + ','.join(('%s',)*len(params))+')'
    db = connection()
    if not db:
        return None
    cur = db.cursor()
    try:
        cur.execute( sql, params )
        if _autocommit:
            db.commit()
    except:
        if _autocommit:
            db.rollback()
        raise
    return cur

def executeScalar(  sql, *params ):
    cur = execute( sql, *params )
    for r in cur:
        if len(r) == 1:
            return r[0]
        break
    return None

def executeRow(  sql, *params ):
    cur = execute( sql, *params )
    for r in cur:
        return r
        break
    return None

def beginTransaction( ):
    global _autocommit
    if _db:
        _db.commit()
        _autocommit = False

def commit( ):
    global _autocommit
    if _db:
        _db.commit()
        _autocommit = True

def rollback( ):
    global _autocommit
    if _db:
        _db.rollback()
        _autocommit = True

