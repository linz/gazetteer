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

import sys

from PyQt4.QtCore import *
from PyQt4.QtGui import *

def handleException():
    type, value, traceback = sys.exc_info()
    if type == None:
        return
    QMessageBox.warning(QApplication.instance().activeWindow(),'Error',str(value))
