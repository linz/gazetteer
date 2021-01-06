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


import os.path
from builtins import str

from PyQt5.QtCore import *
from PyQt5.QtGui import *

from LINZ.Widgets import QtUtils
from LINZ.gazetteer.Model import SystemCode
from LINZ.gazetteer.gui.Controller import Controller


def populateCodeCombo(combo, code_group, showAny=False, special=None, category=None):
    codes = SystemCode.codeGroup(code_group)
    rows = [
        (c.code, c.value) for c in codes if category == None or c.category == category
    ]
    rows.sort(key=lambda x: str(x[1]).upper())
    if special:
        rows[0:0] = special
    if showAny:
        rows.insert(0, (None, "(Any)"))
    QtUtils.populateCombo(combo, rows)
    combo.setCurrentIndex(0)
