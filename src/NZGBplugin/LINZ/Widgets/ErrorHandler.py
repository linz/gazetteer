import sys

from PyQt4.QtCore import *
from PyQt4.QtGui import *

def handleException():
    type, value, traceback = sys.exc_info()
    if type == None:
        return
    QMessageBox.warning(QApplication.instance().activeWindow(),'Error',str(value))
