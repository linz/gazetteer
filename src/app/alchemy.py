import sys
import sqlalchemy
import sqlalchemy.orm
import sqlalchemy.sql
import sqlalchemy.schema
from postgis.postgis import GISColumn, Geometry
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, Unicode;

# engine = sqlalchemy.create_engine('postgresql+psycopg2://<user>:<pass>@localhost/<path>')
engine = sqlalchemy.create_engine('postgresql+psycopg2://<user>@localhost/<path>');#,client_encoding='utf8') #,echo=True)

Session = sqlalchemy.orm.sessionmaker(bind=engine)
s = Session()

meta = sqlalchemy.schema.MetaData( bind=engine )
base=declarative_base(metadata=meta)

class codes(base):
    __tablename__ = 'system_code'
    __table_args__ ={ 'schema':'gazetteer','autoload':True}


for f in s.query(codes).all():
    print type(f.value)
    print f.value.encode('ascii','ignore')

#features = sqlalchemy.schema.Table('feature',meta,schema='gazetteer',autoload=True)
#print features


#class Feature(base):
#    __tablename__='feature'
#    __table_args__={'schema':'gazetteer'}
#    feat_id=Column(Integer,primary_key=True)
#    description=Column(String(convert_unicode=True))
#    status=Column(String(4))

class Feature(base):
    __tablename__='feature'
    __table_args__={ 
        'schema':'gazetteer',
        'autoload':True
         }
    ref_point = GISColumn(Geometry(2))
    names = sqlalchemy.orm.relationship('Name',backref='feature')


    def __str__(self):
        return 'Feature<'+str(self.feat_id)+'>'

class Name(base):
    __table__=sqlalchemy.schema.Table('name',meta,schema='gazetteer',autoload=True)
    events = sqlalchemy.orm.relationship('Event',backref='name')

    def __str__(self):
        return 'Name<'+str(self.name)+'>'


class Event(base):
    __table__=sqlalchemy.schema.Table('name_event',meta,schema='gazetteer',autoload=True)

    def __str__(self):
        return 'NameEvent<'+str(self.event_id)+'>'


#print dir(Feature)
print '--------'
#print dir(Feature.__table__)
print dir(Feature.feat_id)
print Feature.__table__.c['feat_id'].type.python_type
print Feature.__table__.c['description'].type.python_type
print Feature.__table__.c['ref_point'].type.python_type
print '--------'
#print dir(Feature.__table__.c['feat_id'])
sys.exit()

# f = Feature(feat_id=10004);
f = s.query(Feature).get(10004)

print f
print f.description
print f.feat_type
print s.scalar(f.ref_point.wkt)
print [x.name for x in f.names]
print "Dirty" if f in s.dirty else "Clean"
f.feat_type='GLCR'
print "After change to same type type","Dirty" if f in s.dirty else "Clean"
f.feat_type='IFLW'
print "After change type","Dirty" if f in s.dirty else "Clean"
f.feat_type='GLCR'
print "After reset original type","Dirty" if f in s.dirty else "Clean"
f = s.query(Feature).get(10004)
print "After requery","Dirty" if f in s.dirty else "Clean"
print f.feat_type
f.feat_type='IFLW'
s.expire(f)
print f.feat_type
print "After expire","Dirty" if f in s.dirty else "Clean"
f2 = s.query(Feature).get(10004)
print f.feat_type
print f2.feat_type

def lf( target, value, oldvalue, initiator ):
    print 'Heard',str(target),' set from ',str(oldvalue),' to ',str(value)

from sqlalchemy import event
event.listen(Feature.feat_type,'set',lf)

print '---------------------'
print type(f).__table__
print f.__getattribute__('feat_type')

f2.feat_type='IFLW'
f2.feat_type='IFLW'
print '--- after changing f2 ---'
print f.feat_type
print f2.feat_type
print '--- after merge f2 ---'
s.merge(f2)
print f.feat_type
print f2.feat_type

print '-- Names --'
n = f.names[0]
print n
print dir(n)

#codes = sqlalchemy.schema.Table('system_code',meta,schema='gazetteer',autoload=True)
#print s.query(codes).all()

# select = sqlalchemy.sql.select([codes],codes.c.code_group=='NEVT')
# conn = engine.connect()
# 
# result = conn.execute(select)
# try:
#     for r in result:
#         print r['code'],r['value']
# finally:
#     result.close()
