
from Adaptor import Adaptor

class DictionaryAdaptor( Adaptor ):

    def _getObjectValue( self, object, attribute ):
        return object[attribute]

    def _setObjectValue( self, object, attribute, value ):
        object[attribute] = value
