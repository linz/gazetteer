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
import getpass
import psycopg2

db_def = dict(
    host="localhost", database="gazetteer", user=getpass.getuser(), password=""
)

args = {"-h": "host", "-d": "database", "-U": "user", "-P": "password"}

i = 0
while i < len(sys.argv) - 1:
    if sys.argv[i] in args:
        db_def[args[sys.argv[i]]] = sys.argv[i + 1]
        sys.argv[i : i + 2] = []
    else:
        i += 1


def db():
    return psycopg2.connect(**db_def)
