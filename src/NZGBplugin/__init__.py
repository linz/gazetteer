#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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


from __future__ import absolute_import
from .Plugin import Plugin


def classFactory(iface):
    return Plugin(iface)
