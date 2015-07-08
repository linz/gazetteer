
from PyQt4.QtCore import *
from PyQt4.QtGui import *

class UCaseRegExpValidator( QRegExpValidator ):
    
    def __init__( self, regexp, parent=None):
        QRegExpValidator.__init__( self, QRegExp(regexp), parent )
        
    def validate( self, string, pos ):
        return QRegExpValidator.validate(self,string.upper(),pos)
    
