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


def populateCombo( widget, rows, display='' ):
    '''
    Populate a QComboWidget with a list of items defined by in iterator
    returning either single values, or [value, string] pairs.

    Optionally can have a display element, which is either a function to
    get the display value from each object in the list, or the name of an
    attribute to use for displaying each item.
    '''
    if isinstance(rows,dict):
        r = [(k,unicode(rows[k])) for k in rows.keys()]
        r.sort(lambda a, b: cmp(a[1],b[1]))
        rows = r
    widget.clear()
    first = True
    addItem = None
    if callable(display):
        addItem = lambda r: widget.addItem(unicode(display(r)),r)
    elif display:
        addItem=lambda r: widget.addItem(unicode(r.__getattribute__(display)),r)
    for r in rows:
        if addItem == None:
            if isinstance(r, list) or isinstance(r, tuple):
                if len(r) > 1:
                    addItem = lambda r: widget.addItem( unicode(r[1]),r[0])
                else:
                    addItem = lambda r: widget.addItem( unicode(r[0]),r[0])
            else:
                addItem = widget.addItem( unicode(r), r )
        addItem(r)

    widget.setCurrentIndex(-1)

def comboValue( widget ):
    '''
    Retrieve the value of a combo box as a python object
    '''
    index = widget.currentIndex()
    if index == -1:
        return None
    return widget.itemData( index )

