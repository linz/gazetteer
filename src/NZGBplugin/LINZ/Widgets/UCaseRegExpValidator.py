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


from PyQt5.QtCore import *
from PyQt5.QtGui import *


class UCaseRegExpValidator(QRegExpValidator):
    def __init__(self, regexp, parent=None):
        QRegExpValidator.__init__(self, QRegExp(regexp), parent)

    def validate(self, string, pos):
        return QRegExpValidator.validate(self, string.upper(), pos)
