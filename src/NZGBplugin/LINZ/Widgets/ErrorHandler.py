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

import sys

from PyQt4.QtCore import *
from PyQt4.QtGui import *

def handleException():
    type, value, traceback = sys.exc_info()
    if type == None:
        return
    QMessageBox.warning(QApplication.instance().activeWindow(),'Error',str(value))
