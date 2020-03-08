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


from Adaptor import Adaptor

class DictionaryAdaptor( Adaptor ):

    def _getObjectValue( self, object, attribute ):
        return object[attribute]

    def _setObjectValue( self, object, attribute, value ):
        object[attribute] = value
