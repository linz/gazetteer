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

from qgis.PyQt.QtWidgets import QMessageBox, QApplication


def handleException():
    type, value, traceback = sys.exc_info()
    if type is None:
        return
    QMessageBox.warning(QApplication.instance().activeWindow(), "Error", str(value))
