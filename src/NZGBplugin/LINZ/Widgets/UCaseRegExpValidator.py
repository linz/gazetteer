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


from PyQt4.QtCore import *
from PyQt4.QtGui import *

class UCaseRegExpValidator( QRegExpValidator ):
    
    def __init__( self, regexp, parent=None):
        QRegExpValidator.__init__( self, QRegExp(regexp), parent )
        
    def validate( self, string, pos ):
        return QRegExpValidator.validate(self,string.upper(),pos)
    
