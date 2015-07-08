################################################################################
#
# Copyright 2015 Crown copyright (c)
# Land Information New Zealand and the New Zealand Government.
# All rights reserved
#
# This program is released under the terms of the new BSD license. See the 
# LICENSE file for more information.
#
################################################################################


from Adaptor import Adaptor

class DictionaryAdaptor( Adaptor ):

    def _getObjectValue( self, object, attribute ):
        return object[attribute]

    def _setObjectValue( self, object, attribute, value ):
        object[attribute] = value
