from qgis import utils
import traceback
import os

# Disable QGIS modal error dialog.

def _showException(type, value, tb, msg, messagebar=False):
    print(msg)
    logmessage = ''
    for s in traceback.format_exception(type, value, tb):
        logmessage += s.decode('utf-8', 'replace') if hasattr(s, 'decode') else s
    print(logmessage)

def _open_stack_dialog(type, value, tb, msg, pop_error=True):
    print(msg)

utils.showException = _showException
utils.open_stack_dialog = _open_stack_dialog

# set gazetteer database environmental vars
os.environ["GAZETTEER_DBHOST"] = ${PGHOST}
os.environ["GAZETTEER_DBPORT"] = "7432"
os.environ["GAZETTEER_DBUSER"] = ${PGPASSWORD}
os.environ["GAZETTEER_DBSCHEMA"] = ${PGDATABASE}
os.environ["GAZETTEER_DBUSERPASS"] = ${PGPASSWORD}
