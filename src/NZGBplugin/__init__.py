#!/usr/bin/env python
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


from Plugin import Plugin

def name():
    return Plugin.LongName

def description():
    return Plugin.Description

def version():
    return Plugin.Version

def qgisMinimumVersion():
    return Plugin.QgisMinimumVersion

def authorName():
    return Plugin.Author

def classFactory(iface):
    return Plugin(iface)

def icon():
    return 'icon.png'


