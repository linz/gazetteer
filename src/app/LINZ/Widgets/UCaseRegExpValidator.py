
from PyQt4.QtCore import *
from PyQt4.QtGui import *

class UCaseRegExpValidator( QRegExpValidator ):
    
    def __init__( self, regexp, parent=None):
        QRegExpValidator.__init__( self, QRegExp(regexp), parent )
        
    def validate( self, string, pos ):
        string.replace(0,string.size(),string.toUpper())
        return QRegExpValidator.validate(self,string,pos)
    
