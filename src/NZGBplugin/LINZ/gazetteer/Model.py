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

from builtins import str
import sys
import warnings
import sqlalchemy
from sqlalchemy.orm import relationship, backref
import sqlalchemy.sql
import sqlalchemy.exc
import sqlalchemy.schema
import geoalchemy2 as ga
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, Unicode, DateTime
from sqlalchemy.schema import Table, MetaData, PrimaryKeyConstraint
from sqlalchemy.sql.expression import Function

from . import Database

meta = MetaData(bind=Database.engine(), schema="gazetteer")
base = declarative_base(metadata=meta)


def objectClass(objtype):
    """
    Derive the class of an objet given its name
    """
    module = sys.modules[__name__]
    if objtype not in dir(module):
        raise ValueError("Invalid object type: " + objtype)
    oclass = getattr(module, objtype)
    if "__table__" not in dir(oclass):
        raise ValueError("Invalid object typeid: " + objtype)
    return oclass


def objectId(item):
    """
    Create a string id for a database derived object that can be
    used to identify the object in application code
    """
    if item == None:
        return None
    if "__table__" not in dir(item):
        return None

    return (
        item.__class__.__name__
        + "_"
        + "_".join(
            [
                str(item.__getattribute__(c.name))
                for c in item.__table__.columns
                if c.primary_key
            ]
        )
    )


def idObject(id):
    """
    Return the database object basedon the id created by objectId
    """
    parts = id.split("_")
    oclass = objectClass(parts[0])
    pcols = [c.name for c in oclass.__table__.columns if c.primary_key]
    if len(pcols) != len(parts) - 1:
        raise ValueError("Invalid object id: " + id)
    return Database.query(oclass).get(*parts[1:])


def newObject(objtype):
    """
    Generate a new object of a specified type
    """
    oclass = objectClass(objtype)
    return oclass()


def objectAttrId(item, attr):
    """
    Create an id for an attribute of a specific object
    """
    id = objectId(item) + "." + attr
    value = item.__getattribute__(attr)
    return id, value


def setObjectAttr(id, value):
    """
    Set an object attribute based on the attribute id derived in
    objectAttrId
    """
    objid, attr = id.split(".", 1)
    item = idObject(objid)
    item.__setattr__(attr, value)


# ====================================================================
# Reflection based ORM classes
#


class User(base):
    __table__ = Table(
        "gazetteer_users", meta, PrimaryKeyConstraint("userid"), autoload=True
    )


class SystemCode(base):
    __table__ = Table("system_code", meta, autoload=True)
    # __tablename__ = 'system_code'
    # __table_args__ ={ 'schema':'gazetteer','autoload':True}

    __codes__ = {}
    __codegroups__ = {}

    def canBeDeleted(self):
        result = Database.scalar(
            "select gazetteer.gaz_canDeleteSystemCode(:code_group,:code)",
            code_group=self.code_group,
            code=self.code,
        )
        return True if result else False

    @staticmethod
    def get(code_group, code):
        return Database.query(SystemCode).get((code_group, code))

    @staticmethod
    def codeGroupCategory(code_group):
        cg = SystemCode.get("CATE", code_group)
        return cg.category if cg else None

    @staticmethod
    def codeGroup(code_group, refresh=False):
        if refresh or code_group not in SystemCode.__codegroups__:
            group = list(
                Database.query(SystemCode)
                .filter(SystemCode.code_group == code_group)
                .all()
            )
            SystemCode.__codegroups__[code_group] = group
        return SystemCode.__codegroups__[code_group]

    @staticmethod
    def codeMapping(code_group, refresh=False):
        if refresh or code_group not in SystemCode.__codes__:
            cv = {}
            for r in SystemCode.codeGroup(code_group, refresh):
                cv[r.code] = r.value
            SystemCode.__codes__[code_group] = cv
        return SystemCode.__codes__[code_group]

    @staticmethod
    def lookup(code_group, code, default=None):
        return SystemCode.codeMapping(code_group).get(code, default)

    @staticmethod
    def lookupCategory(code_group, code):
        scode = SystemCode.get(code_group, code)
        if scode:
            return scode.category
        return None


class Feature(base):
    __tablename__ = "feature"
    # __table_args__ ={ 'schema':'gazetteer'}

    # Not using autoload as creates issues with geometry at the moment :-(
    feat_id = Column(Integer, primary_key=True)
    feat_type = Column(Unicode(4))
    status = Column(Unicode(4))
    description = Column(Unicode)
    ref_point = Column(ga.Geometry(geometry_type="POINT", srid=4167))
    updated_by = Column(Unicode(64))
    update_date = Column(DateTime)

    names = relationship("Name", backref="feature", cascade="all, delete-orphan")
    annotations = relationship(
        "FeatureAnnotation", backref="feature", cascade="all, delete-orphan"
    )

    def preferredName(self):
        id = Database.scalar(Database.func.gazetteer.gaz_preferredNameId(self.feat_id))
        return Name.get(id)

    @staticmethod
    def get(id):
        return Database.query(Feature).get(id)

    def location(self, srid=4167):
        if Database.session().is_modified(self):
            raise RuntimeError("Cannot query location of modifed feature")
        result = Database.querysql(
            """
            select st_x(pt),st_y(pt) from
            (select st_transform(ref_point,:srid) as pt from gazetteer.feature
             where feat_id=:id) as ptq
            """,
            id=self.feat_id,
            srid=srid,
        ).fetchone()
        return [float(result[0]), float(result[1])]

    def setLocation(self, xy, srid=4167):
        wkt = Database.scalar(
            "select st_astext(st_transform(st_setsrid(st_point(:x,:y),:srid),4167))",
            x=xy[0],
            y=xy[1],
            srid=srid,
        )
        self.ref_point = ga.WKTElement(wkt, srid=srid)

    def __str__(self):
        return "Feature<" + str(self.feat_id) + ">"


class Name(base):
    # __table__=Table('name',meta,schema='gazetteer',autoload=True)

    # Skip warning about full text index which cannot be handled in reflection
    # with warnings.catch_warnings():

    wfilters = warnings.filters[:]
    warnings.simplefilter("ignore")
    try:
        warnings.simplefilter("ignore", category=sqlalchemy.exc.SAWarning)
        __table__ = Table("name", meta, autoload=True)
    finally:
        warnings.filters = wfilters

    events = relationship("Event", backref="name", cascade="all, delete-orphan")
    annotations = relationship(
        "NameAnnotation", backref="name", cascade="all, delete-orphan"
    )

    def __str__(self):
        return "Name<" + str(self.name) + ">"

    @staticmethod
    def get(id):
        return Database.query(Name).get(id)

    @staticmethod
    def search(name=None, ftype=None, status=None, maxresults=None):
        if name:
            name = Database.build_tsquery(name)
        nresults = maxresults if maxresults else None
        results = Database.querysql(
            """
            select name_id, feat_id, name, name_status, feat_type, rank
            from gazetteer.gaz_searchname(:name,:ftype,:status,:nmax)
            order by rank desc, name""",
            name=name,
            ftype=ftype,
            status=status,
            nmax=nresults,
        ).fetchall()
        if nresults and len(results) == nresults:
            results = []
            raise ValueError("Query is not specific enough")
        return results

    @staticmethod
    def search2(
        name=None,
        ftype=None,
        status=None,
        notpublished=False,
        extentWkt=None,
        maxresults=None,
    ):
        if name:
            name = Database.build_tsquery(name)
        nresults = maxresults + 1 if maxresults else None
        results = Database.querysql(
            """
            select name_id, feat_id, name, name_status, feat_type, rank
            from gazetteer.gaz_searchname2(:name,:ftype,:status,:wkt,:npub,:nmax)
            order by rank desc, name""",
            name=name,
            ftype=ftype,
            status=status,
            npub=notpublished,
            wkt=extentWkt,
            nmax=nresults,
        ).fetchall()
        if nresults and len(results) == nresults:
            results = []
            raise ValueError("More than " + str(maxresults) + " matches found")
        results.sort(key=lambda x: x["rank"])
        return results


class Event(base):
    __table__ = Table("name_event", meta, autoload=True)

    def __str__(self):
        return "NameEvent<" + str(self.event_id) + ">"


class FeatureAnnotation(base):
    __table__ = Table("feature_annotation", meta, autoload=True)

    def __str__(self):
        return "FeatureAnnotation<" + str(self.annot_id) + ">"


class NameAnnotation(base):
    __table__ = Table("name_annotation", meta, autoload=True)

    def __str__(self):
        return "NameAnnotation<" + str(self.annot_id) + ">"


class NameAssociation(base):
    __table__ = Table("name_association", meta, autoload=True)

    name_from = relationship(
        "Name",
        primaryjoin="NameAssociation.name_id_from==Name.name_id",
        backref="associated_to",
    )
    name_to = relationship(
        "Name",
        primaryjoin="NameAssociation.name_id_to==Name.name_id",
        backref=backref(
            "associated_from",
            primaryjoin="and_(NameAssociation.name_id_to==Name.name_id, "
            "func.gazetteer.gaz_nameRelationshipIsTwoWay(NameAssociation.assoc_type))",
        ),
    )


class FeatureAssociation(base):
    __table__ = Table("feature_association", meta, autoload=True)

    feat_from = relationship(
        "Feature",
        primaryjoin="FeatureAssociation.feat_id_from==Feature.feat_id",
        backref="associated_to",
    )
    feat_to = relationship(
        "Feature",
        primaryjoin="FeatureAssociation.feat_id_to==Feature.feat_id",
        backref=backref(
            "associated_from",
            primaryjoin="and_(FeatureAssociation.feat_id_to==Feature.feat_id,"
            "func.gazetteer.gaz_featureRelationshipIsTwoWay( FeatureAssociation.assoc_type))",
        ),
    )


# Ensure all relationships are instantiated
sqlalchemy.orm.configure_mappers()
