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

from builtins import str
from builtins import object
import re
import os
import sys
import getpass

import sqlalchemy
from sqlalchemy.orm import scoped_session, sessionmaker
from sqlalchemy.sql import expression

from sqlalchemy import event
from sqlalchemy.pool import Pool
from sqlalchemy.sql import text

_host = os.environ.get("PGHOST") or "prdassgzdb01"
_port = os.environ.get("PGPORT") or "5432"
_database = os.environ.get("PGDATABASE") or "gazetteer"
_schema = os.environ.get("PGSCHEMA") or "gazetteer"
_user = os.environ.get("PGUSER") or getpass.getuser()
_password = os.environ.get("PGPASSWORD") or None
_instance = None


func = expression.func


def set_search_path(db_conn, conn_proxy):
    sql = "set search_path=" + _schema + ", public"
    db_conn.cursor().execute(sql)


class Database(object):
    def __init__(self):
        global _host, _port, _database, _schema, _user

        connection_string = "/" + _database + "?host=" + _host
        if _port:
            connection_string += "&port=" + _port

        if _user:
            user = _user
            user = user + ":" + (_password or "")
            connection_string = user + "@" + connection_string
        connection_string = "postgresql+psycopg2://" + connection_string

        self._engine = sqlalchemy.create_engine(connection_string)
        # event.listen(self._engine, 'connect', set_search_path )
        event.listen(Pool, "connect", set_search_path)
        self._session = None

    def engine(self):
        return self._engine

    def session(self):
        if not self._session:
            Session = scoped_session(sessionmaker(bind=self._engine))
            self._session = Session()
            sql = "set search_path=" + _schema + ", public"
            self._session.execute(sql)
        return self._session


def setConnection(
    host=None, port=None, database=None, schema=None, user=None, password=None
):
    global _host, _database, _schema, _user, _port, _password
    changed = False
    if host is not None and host != _host:
        _host = host
        changed = True
    if port is not None and port != _port:
        _port = port
        changed = True
    if database is not None and database != _database:
        _database = database
        changed = True
    if schema is not None and schema != schema:
        _schema = schema
        changed = True
    if user is not None and user != _user:
        _user = user
        changed = True
    if password is not None and password != _password:
        _password = password
        changed = True
    if changed and _instance:
        raise RuntimeError(
            "Cannot set connection to database after it has been instantiated"
        )


def getConnection():
    global _host, _port, _database, _schema, _user, _password
    return {
        "host": _host,
        "port": _port,
        "database": _database,
        "schema": _schema,
        "user": _user,
        "password": _password,
    }


def instance():
    global _instance, _user
    admins = None
    if not _instance:
        try:
            _instance = Database()
            if not userIsValid():
                _instance = None
                admins = gazetteerAdmins()
        except:
            msg = str(sys.exc_info()[1])
            raise RuntimeError(
                "Current user "
                + str(_user)
                + " is not authorized to access the gazetteer database.\n"
                + msg
            )

    if not _instance:
        raise RuntimeError(
            "Current user "
            + str(_user)
            + " is not authorized to access the gazetteer database\n"
            + "Contact a gazetteer admin:\n    "
            + "\n    ".join(admins)
        )

    return _instance


def engine():
    return instance().engine()


def session():
    return instance().session()


def commit():
    try:
        session().commit()
    except:
        session().rollback()
        raise


def rollback():
    session().rollback()


def add(object_):
    session().add(object_)


def delete(object_):
    session().delete(object_)


def scalar(sql, **kwargs):
    if type(sql) in (str, str):
        sql = text(sql)
    try:
        return session().scalar(sql, kwargs)
    except:
        rollback()
        raise


def query(*args, **kwargs):
    return session().query(*args, **kwargs)


def querysql(sql, **kwargs):
    if type(sql) in (str, str):
        sql = text(sql)
    try:
        return session().execute(sql, kwargs)
    except:
        rollback()
        raise


def execute(sql, **kwargs):
    if type(sql) in (str, str):
        sql = text(sql)
    try:
        session().execute(sql, kwargs)
        commit()
    except:
        rollback()
        raise


def build_tsquery(text):
    text = scalar("select gazetteer.gaz_plainText2(:text)", text=text)
    return " & ".join([re.sub(r"\*$", ":*", x) for x in text.split()])


def user():
    return scalar("select current_user")


def users():
    return [
        dict(userid=r[0], isdba=r[1])
        for r in querysql("select userid, isdba from gazetteer.gazetteer_users")
    ]


def userIsValid():
    return scalar("select gazetteer.gaz_IsGazetteerUser()")


def userIsDba():
    return scalar("select gazetteer.gaz_IsGazetteerDba()")


def gazetteerAdmins():
    admins = []
    for r in querysql("select userid from gazetteer_users where isdba"):
        admins.append(str(r[0]))
    return admins
