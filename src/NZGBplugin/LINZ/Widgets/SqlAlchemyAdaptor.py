from __future__ import absolute_import
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


from .Adaptor import Adaptor
from sqlalchemy.orm.properties import RelationshipProperty

class SqlAlchemyAdaptor( Adaptor ):
    '''
    Adaptor class for SqlAlchemy model classes.
    '''

    _adaptors={}

    @staticmethod
    def getAdaptor( modelClass ):
        if modelClass in SqlAlchemyAdaptor._adaptors:
            return SqlAlchemyAdaptor._adaptors[modelClass]
        return SqlAlchemyAdaptor(modelClass)

    def __init__( self, modelClass ):
        Adaptor.__init__( self )
        SqlAlchemyAdaptor._adaptors[modelClass] = self
        
        table = modelClass.__table__
        self.setTypeName( modelClass.__name__)
        primary=[]
        for c in table.columns:
            if c.primary_key:
                primary.append(c.name)
            try:
                self.addAttribute(c.name, c.type.python_type, editable=not c.primary_key)
            # For Geometry type, which doesn't implement python_type yet.
            except NotImplementedError:
                pass

        if len(primary) == 1:
            self.setIdAttribute( primary[0] )

        for relname in dir(modelClass):
            if relname.startswith("_"):
                continue
            rel= type(modelClass).__getattribute__(modelClass,relname)
            if 'property' not in dir(rel):
                continue
            prop = rel.property
            if not isinstance(prop,RelationshipProperty):
                continue
            adaptor = SqlAlchemyAdaptor.getAdaptor(prop.mapper.class_)
            islist = prop.uselist
            self.addAttribute( relname, adaptor, editable=True, islist=islist )

    def _getObjectValue( self, object, attribute ):
        return object.__getattribute__(attribute)

    def _setObjectValue( self, object, attribute, value ):
        object.__setattr__(attribute,value)
