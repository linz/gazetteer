#!/usr/bin/env python3
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


from LINZ.gazetteer import Config


syntax = """
Configure the gazetter database

Supply any required configuration parameters as command line parameters like:
    host=
    port=
    database=
    schema=
    user=
    password=

Or use "show" to show the current settings,
"reset" to remove local settings,
or "check" to check connectivity to database

"""

if __name__ != "__main__":
    from LINZ.gazetteer.Database import Database

    Database.update_connection_details()
else:
    import sys
    from os.path import dirname, abspath

    sys.path.append(dirname(dirname(dirname(dirname(abspath(__file__))))))
    from LINZ.gazetteer import Database

    if len(sys.argv) < 2:
        print(syntax)
        sys.argv.append("show")

    keys = "host port database schema user password".split()
    options = {}
    argsok = True
    reset = False
    show = False
    check = False
    for arg in sys.argv[1:]:
        if arg == "reset":
            reset = True
            continue
        if arg == "show":
            show = True
            continue
        if arg == "check":
            show = True
            check = True
            continue
        if "=" not in arg:
            print("Invalid argument:", arg)
            argsok = False
            break
        key, value = arg.split("=", 1)
        if key not in keys:
            print("Invalid argument:", arg)
            argsok = False
            break
        options[key] = value

    if not argsok:
        print(syntax)
        sys.exit()

    if reset:
        for key in keys:
            Config.remove("Database/" + key)
        print("Default database configuration restored")

    for key, value in list(options.items()):
        if not value:
            Config.remove("Database/" + key)
        else:
            Config.set("Database/" + key, value)

    print("Configuration set")
    Database.Database.update_connection_details()
    dbconfig = Database.Database.get_connection_details()
    for k in keys:
        print("%s: %s" % (k, dbconfig[k]))

    if check:
        valid = Database.userIsValid()
        dba = Database.userIsDba()
        print("Current user is gazetteer user: ", valid)
        print("Current user is gazetteer dba: ", dba)
