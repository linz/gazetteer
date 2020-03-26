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


from PyQt4.QtCore import *
from PyQt4.QtGui import *

class PythonComboBox( QComboBox ):
    
    def __init__( self, parent=None ):
        QComboBox.__init__(self,parent)
        
    def populate( self, rows, display='' ):
        '''
        Populate a QComboWidget with a list of items defined by in iterator
        returning either single values, or [value, string] pairs
        '''
        if isinstance(rows,dict):
            r = [(k,unicode(rows[k])) for k in rows.keys()]
            r.sort(lambda a, b: cmp(a[1],b[1]))
            rows = r
        self.clear()
        first = True
        addItem = None
        if callable(display):
            addItem = lambda r: self.addItem(unicode(display(r)),r)
        elif display:
            addItem=lambda r: self.addItem(unicode(r.__getattribute__(display)),r)
        for r in rows:
            if addItem == None:
                if isinstance(r, list) or isinstance(r, tuple):
                    if len(r) > 1:
                        addItem = lambda r: self.addItem( unicode(r[1]),r[0])
                    else:
                        addItem = lambda r: self.addItem( unicode(r[0]),r[0])
                else:
                    addItem = self.addItem( unicode(r), r )
            addItem(r)
        self.setCurrentIndex(-1)
        
    def setSelectedItem( self, data ):
        for i in range(self.count()):
            if self.itemData(i) == data:
                self.setCurrentIndex(i)
        
    def selectedItem( self ):
        index = self.currentIndex()
        if index == -1:
            return None
        return self.itemData( index )