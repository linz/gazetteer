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


class ListModelConnector( QAbstractTableModel ):
    ''' 
    Represents a list of objects which are accessed via an Adaptor as in a QAbstractTableModel,
    for incorporating into a QTableView or similar.

    Has support for filtering objects (based on a lambda function), sorting.  Objects can be
    defined as editable.
    '''


    itemUpdated = pyqtSignal( int, name="itemUpdated" )
    resettingModel = pyqtSignal( name="resettingModel" )

    def __init__( self, adaptor=None, list=None, columns=None, headers=None, idColumn=None, filter=None ):
        QAbstractTableModel.__init__(self)
        self._adaptor=None
        self._columns = []
        self._headers = []
        self._editCols = []
        self._editable = []
        self._idColumn = None
        self._filter = None
        self._sortColumn = None
        self._sortReverse = False
        self._index = []
        self._lookup = None
        self._idLookup = None
        self._readonlyBrush = None
        self.setList( list, adaptor, columns, headers, idColumn, filter )

    def list( self ):
        '''
        Get the current item list
        '''
        return self._list

    def setList( self, list=[], adaptor=None, columns=None, headers=None, idColumn=None, filter=None ):
        '''
        Attach a new item list to the model.  The columns, headers, and id column
        will be based on the first item in the list if they are not defined 
        explicitely
        '''
        self.resettingModel.emit()
        if adaptor:
            self._adaptor = adaptor
        self._list = list if list != None else []
        if self._list and not self._adaptor:
            raise RuntimeError('ListModelConnector cannot use a list without having an adaptor defined')


        if not columns: columns = []

        self._createIndex()
        if idColumn:
            self._idColumn = idColumn
        self._setColumns( columns, headers )
        self._resetList()
        if filter:
            self.setFilter(filter)

    def setEditColumns( self, editColumns ):
        '''
        Specify a list of columns that will be editable
        '''
        self._editable = [False] * len(self._columns)
        self._editCols = editColumns
        if editColumns:
            for editCol in editColumns:
                try:
                    attrdef = self._adaptor.getAttrDef(editCol)
                    if not attrdef.editable():
                        continue
                except:
                    continue
                for i, col in enumerate(self._columns):
                    if editCol == col:
                        self._editable[i] = True

    def setFilter( self, filter=None ):
        '''
        Define a filter function restricting the list of items to display.  The
        function takes an item as a parameter, and returns a True value if the 
        item is to be displayed in the view.
        '''
        self.resettingModel.emit()
        self._filter = filter
        self._createIndex()
        self._resetList()

    def resetFilter( self ):
        '''
        Reapply the current filter to respond to data changes etc.
        '''
        self.resettingModel.emit()
        self._createIndex()
        self._resetList()

    def setColumns( self, columns=None, headers=None ):
        '''
        Reset the column and header names
        '''
        self.resettingModel.emit()
        self._setColumns( columns, headers )
        self._resetList()

    def _setColumns( self, columns, headers ):
        '''
        Reset the columns and column headers.  If values are provided use them.
        Otherwise use already set values, or if none, infer values from the 
        first item in the list.
        '''
        if columns:
            self._columns = columns
            self._headers = headers
        if self._adaptor and not self._columns:
            self._columns = self._adaptor.attributes()
        if not self._headers or len(self._headers) != len(self._columns):
            self._headers = self._columns
        self._editable = [False] * len(self._columns)
        self.setIdColumn( self._idColumn )
        self.setEditColumns( self._editCols )

    def setIdColumn( self, idColumn ):
        '''
        Specify a attribute to use as the object id
        '''
        if not idColumn and self._adaptor:
            idColumn = self._adaptor.idattribute()
        self._idColumn = idColumn
        self._idLookup = None

    def setReadonlyColour( self, colour ):
        '''
        Set the colour to use for readonly colours
        '''
        self._readonlyBrush = QBrush(colour)

    def _createIndex( self ):
        '''
        Create the index mapping list index to view rows 
        '''
        if self._filter:
            self._index = [i 
                           for i in range(len(self._list)) 
                           if self._filter(self._list[i])]
        else:
            self._index = range( len( self._list) )
        self._sortIndex()
        self._lookup = None

    def getDisplayRow( self, row ):
        '''
        Get the list index corresponding to a view row
        '''
        if row == None:
            return None
        if row < 0 or row >= len(self._list):
            return None
        if self._lookup == None:
            lookup = [None] * len( self._list)
            for i in range(len(self._index)):
                lookup[self._index[i]] = i
            self._lookup = lookup
        return self._lookup[row]

    def _resetList( self ):
        '''
        Emit the modelReset event
        '''
        self.modelReset.emit()

    def count( self ):
        '''
        Alternative to rowCount
        '''
        return len( self._index )

    def rowCount( self, parent ): 
        '''
        Overloaded function returning the row count
        '''
        return len(self._index) if not parent.isValid() else 0

    def columnCount( self, parent ): 
        '''
        Overloaded function returning the column count
        '''
        return len(self._columns) if not parent.isValid() else 0

    def getItem( self, row ):
        '''
        Get the item for a specific view row
        '''
        if row != None and row >= 0 and row < len( self._index ):
            return self._list[self._index[row]]
        return None

    def getItems( self, rows ):
        '''
        Get the items for a list of view rows
        '''
        return [self.getItem(r) for r in rows]

    def itemFromIndex( self, index ):
        '''
        Returns the object and attribute name corresponding to an
        index value (defines view row() and column())
        '''
        object = self._list[self._index[index.row()]]
        attr = self._columns[index.column()]
        return object, attr

    def getId( self, row ):
        '''
        Get the id of the object in the specified row
        '''
        if self._idColumn == None:
            return None
        item = self.getItem( row )
        if not item:
            return None
        return self._getItemAttribute(item,self._idColumn)

    def getIdRow( self, id ):
        '''
        Get the source row number of the object with the specified id
        '''
        if not self._idLookup:
            self._idLookup=dict()
            if self._idColumn:
                for i in range(len(self._list)):
                    itemid = self._getItemAttribute(self._list[i],self._idColumn)
                    if itemid:
                        self._idLookup[itemid] = i
        return self._idLookup.get(id)

    def getIdDisplayRow( self, id ):
        '''
        Get the view row number of the object with the specified id
        '''
        return self.getDisplayRow( self.getIdRow( id ))

    def flags( self, index ):
        '''
        Overloaded function to return item flags
        '''
        flag = Qt.ItemIsEnabled | Qt.ItemIsSelectable
        if self._editable[index.column()]:
            flag |= Qt.ItemIsEditable
        return flag


    def data( self, index, role ):
        '''
        Overloaded function to retrieve information for views
        '''
        col = index.column()
        if role == Qt.DisplayRole or role == Qt.EditRole:
            object, attr = self.itemFromIndex( index )
            attr = self._getItemAttribute(object,attr)
            if attr == None:
                return ''
            return unicode(attr)
        elif role == Qt.BackgroundRole and not self._editable[col] and self._readonlyBrush:
            return self._readonlyBrush
        #return QVariant()
        return None

    def setData( self, index, value, role ):
        '''
        Overloaded function to set data value
        '''
        if not index.isValid() or role != Qt.EditRole:
            return False
        col = index.column()
        if not self._editable[col]:
            return False
        object, attr = self.itemFromIndex( index )
        self._adaptor.setValue(item,attr,unicode(value))
        self.dataChanged.emit(index,index)
        return True

    def headerData( self, section, orientation, role ):
        '''
        Overloaded function to retrieve header data
        '''
        if role == Qt.DisplayRole:
            if orientation == Qt.Horizontal:
                if self._headers and section < len(self._headers):
                    return self._headers[section]
        return None

    def sort( self, column, order ):
        '''
        Function to sort the view, based on a column and order
        '''
        self.layoutAboutToBeChanged.emit()
        self._sortColumn = column
        self._sortReverse = order == Qt.DescendingOrder
        self._sortIndex()
        self.layoutChanged.emit()

    def _sortIndex( self ):
        '''
        Rebuild the sorted index (self._index) mapping between sorted (displayed) list
        and actual list order.  This doesn't change the base list, just the display order
        '''
        if self._sortColumn == None:
            return
        key = self._columns[self._sortColumn]
        keyfunc = lambda x: unicode(self._getItemAttribute(self._list[x],key))
        self._index.sort( None, keyfunc, self._sortReverse )
        self._lookup = None

    def updateItem( self, index ):
        '''
        Reflect item changes into the view
        '''
        row = self.getDisplayRow(index)
        showing = True
        if self._filter:
            showing = row != None
            show = self._filter(self._list[index])
            if showing != show:
                self.resettingModel.emit()
                self._createIndex()
                self._resetList()
        elif showing:
            self.dataChanged.emit(self.index(row,0),self.index(row,len(self._columns)))
        self.itemUpdated.emit( index )

    def _getItemAttribute( self, item, attribute ):
        try:
            return self._adaptor.getValue( item, attribute )
        except:
            return None


class ListModelTableView( QTableView ):
    '''
    ListModelTableView provides some extra signals, default settings, and 
    intelligence to the QTableView to support interacting with a ListModelConnector
    '''

    rowSelected = pyqtSignal( int, name="rowSelected" )
    rowDoubleClicked = pyqtSignal( int, name="rowDoubleClicked" )
    rowSelectionChanged = pyqtSignal( name="rowSelectionChanged" )
    modelReset = pyqtSignal( name="modelReset" )

    def __init__( self, parent=None ):
        QTableView.__init__( self, parent )
        # Change default settings
        self.setSelectionMode(QAbstractItemView.SingleSelection)
        self.setSelectionBehavior(QAbstractItemView.SelectRows)
        self.horizontalHeader().setStretchLastSection(True)
        self.horizontalHeader().setHighlightSections(False)
        self.verticalHeader().setVisible(False)
        self.verticalHeader().setDefaultSectionSize(17)
        self.setSortingEnabled(True)
        self.setEditTriggers(QAbstractItemView.AllEditTriggers)
        self.setStyleSheet("* { gridline-color: gray }")

        # Own variables
        self._model=None
        self._modelList = None
        self._selectedId =None
        self._alternativeId =None

        self.doubleClicked.connect( self.onDoubleClicked )

    # Reimplemented QTableView functions

    def selectionChanged( self, selected, deselected ):
        QTableView.selectionChanged( self, selected, deselected )
        self.rowSelectionChanged.emit()
        row = self.selectedRow()
        self.rowSelected.emit( row )

    def setList( self, list=[], adaptor=None, columns=None, headers=None, idColumn=None, filter=None ):
        model = self.model()
        if isinstance(model,ListModelConnector):
            model.setList(list,adaptor=adaptor,columns=columns,headers=headers,idColumn=idColumn,filter=None)
        else:
            model=ListModelConnector(list=list,adaptor=adaptor,columns=columns,headers=headers,idColumn=idColumn,filter=None)
            self.setModel( model )
            
    def list( self ):
        try:
            return self.model().list()
        except:
            return None

    def setModel( self, model ):
        QTableView.setModel( self, model )
        if self._model:
            self._model.modelReset.disconnect( self._onModelReset )
            self._model.layoutAboutToBeChanged.disconnect( self._saveSelectedRow )
            self._model.layoutChanged.disconnect( self._restoreSelectedRow )
        if self._modelList:
            self._modelList.resettingModel.disconnect( self._saveSelectedRow )
        self._model = model 
        self._modelList = self._model if isinstance(self._model,ListModelConnector) else None
        if self._model:
            self._model.modelReset.connect( self._onModelReset )
            self._model.layoutAboutToBeChanged.connect( self._saveSelectedRow )
            self._model.layoutChanged.connect( self._restoreSelectedRow )
        if self._modelList:
            self._modelList.resettingModel.connect( self._saveSelectedRow )
        self._onModelReset()

    # Select first row by default

    def _saveSelectedRow( self ):
        if not self._modelList:
            self._selectedId = None
            self._alternativeId = None
            return
        self._selectedId = self.selectedId()
        if self._selectedId != None:
            row = self.selectedRow() + 1
            self._alternativeId = self._modelList.getId( row )

    def _restoreSelectedRow( self ):
        if not self.selectId(self._selectedId) and not self.selectId( self._alternativeId ):
            self.selectRow(0)

    def _onModelReset(self):
        self.modelReset.emit()
        if self.rowCount() > 0:
            self.resizeColumnsToContents()
            self._restoreSelectedRow()
        else:
            self.rowSelected.emit( -1 )

    def onDoubleClicked( self, index ):
        row = self.selectedRow()
        if row != None:
            self.rowDoubleClicked.emit( row )

    def selectId( self, id ):
        if self._modelList and id != None:
            row = self._modelList.getIdDisplayRow( id )
            if row != None:
                self.selectRow( row )
                return True
        return False

    def selectedRow( self ):
        rows = self.selectionModel().selectedRows()
        if len(rows) == 1:
            return rows[0].row()
        return None

    def selectedId( self ):
        if not self._modelList:
            return None
        row = self.selectedRow()
        return self._modelList.getId( row )

    def selectedItem( self ):
        return self.itemAt(self.selectedRow())
        
    def itemAt( self, row ):
        if not self._modelList:
            return None
        return self._modelList.getItem( row )

    def selectedRows( self ):
        return [r.row() for r in self.selectionModel().selectedRows()]

    def selectedItems( self ):
        if self._modelList:
            list = self._modelList
            return [list.getItem(r) for r in self.selectedRows()]
        return []

    def rowCount( self ):
        model = self.model()
        if not model:
            return 0
        return model.rowCount(QModelIndex())

