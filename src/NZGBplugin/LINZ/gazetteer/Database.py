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

import re
import os
import sys
import getpass
from typing import Optional, Dict

import sqlalchemy
from sqlalchemy.orm import scoped_session, sessionmaker
from sqlalchemy.sql import expression

from sqlalchemy import event
from sqlalchemy.pool import Pool
from sqlalchemy.sql import text

func = expression.func

from . import Config


class Database(object):
    HOST: Optional[str] = None
    PORT: Optional[str] = None
    DATABASE: Optional[str] = None
    SCHEMA: Optional[str] = None
    USER: Optional[str] = None
    PASSWORD: Optional[str] = None

    _INSTANCE: Optional["Database"] = None

    def __init__(self):
        connection_string = "/" + Database.DATABASE + "?host=" + Database.HOST
        if Database.PORT:
            connection_string += "&port=" + Database.PORT

        if Database.USER:
            user_string = Database.USER + ":" + (Database.PASSWORD or "")
            connection_string = user_string + "@" + connection_string
        connection_string = "postgresql+psycopg2://" + connection_string

        self._engine = sqlalchemy.create_engine(connection_string)
        # event.listen(self._engine, 'connect', set_search_path )
        event.listen(Pool, "connect", Database.set_search_path)
        self._session = None

    def engine(self):
        return self._engine

    def session(self):
        if not self._session:
            Session = scoped_session(sessionmaker(bind=self._engine))
            self._session = Session()
            sql = "set search_path=" + Database.SCHEMA + ", public"
            self._session.execute(sql)
        return self._session

    @staticmethod
    def set_search_path(db_conn, conn_proxy):
        sql = "set search_path=" + Database.SCHEMA + ", public"
        db_conn.cursor().execute(sql)

    @classmethod
    def has_stored_connection_details(cls) -> bool:
        """
        Returns True if the database connection details are stored for the user,
        or False if they have been retrieved from the environment or hardcoded
        defaults
        """
        return Config.contains("Connection") or Config.contains("Database")

    @classmethod
    def stored_connection_name(cls) -> Optional[str]:
        """
        Returns the stored QGIS postgres connection name to use for the database
        connection, or None if not set
        """
        return Config.get("connection_name") or None

    @classmethod
    def set_stored_connection_details(
        cls, connection_name: Optional[str], schema: Optional[str]
    ):
        """
        Sets the stored QGIS postgres connection name and database schema
        to use for the database connection

        If None, the stored connection name is removed
        """
        if connection_name:
            Config.set("connection_name", connection_name)
            Config.set("Database/schema", schema)
        else:
            Config.remove("connection_name")

    @classmethod
    def update_connection_details(cls):
        # default database connection parameters
        # prefer QSettings, then environment, finally hardcoded defaults
        # note that if the QSettings "database" key exists, then we get ALL
        # the database properties from QSettings -- we don't want to fallback to
        # env variables or defaults if a particular configuration key isn't
        # applicable to the stored connection and is set to "" or None
        old_host = cls.HOST
        old_port = cls.PORT
        old_database = cls.DATABASE
        old_schema = cls.SCHEMA
        old_user = cls.USER
        old_password = cls.PASSWORD

        if Config.contains("connection_name"):
            # retrieve QGIS stored connection from QgsSettings
            from qgis.core import QgsSettings

            settings = QgsSettings()

            connection_name = Config.get("connection_name")
            connection_settings_group = f"PostgreSQL/connections/{connection_name}"

            cls.HOST = settings.value(f"{connection_settings_group}/host", None) or None
            cls.PORT = settings.value(f"{connection_settings_group}/port", None) or None
            cls.DATABASE = (
                settings.value(f"{connection_settings_group}/database", None) or None
            )
            cls.SCHEMA = Config.get("Database/schema", None)
            cls.USER = (
                settings.value(f"{connection_settings_group}/username", None) or None
            )
            cls.PASSWORD = (
                settings.value(f"{connection_settings_group}/password", None) or None
            )
        elif Config.contains("Database"):
            cls.HOST = Config.get("Database/host", None)
            cls.PORT = Config.get("Database/port", None)
            cls.DATABASE = Config.get("Database/database", None)
            cls.SCHEMA = Config.get("Database/schema", None)
            cls.USER = Config.get("Database/user", None)
            cls.PASSWORD = Config.get("Database/password", None)
        else:
            cls.HOST = os.environ.get("PGHOST") or "prdassgzdb01"
            cls.PORT = os.environ.get("PGPORT") or "5432"
            cls.DATABASE = os.environ.get("PGDATABASE") or "gazetteer"
            cls.SCHEMA = os.environ.get("PGSCHEMA") or "gazetteer"
            cls.USER = os.environ.get("PGUSER") or getpass.getuser()
            cls.PASSWORD = os.environ.get("PGPASSWORD") or None

        changed = (
            cls.HOST != old_host
            or cls.PORT != old_port
            or cls.DATABASE != old_database
            or cls.SCHEMA != old_schema
            or cls.USER != old_user
            or cls.PASSWORD != old_password
        )
        if changed and cls._INSTANCE:
            raise RuntimeError(
                "Cannot change database connection parameters after it has been instantiated"
            )

    @classmethod
    def get_connection_details(cls) -> Dict[str, Optional[str]]:
        return {
            "host": cls.HOST,
            "port": cls.PORT,
            "database": cls.DATABASE,
            "schema": cls.SCHEMA,
            "user": cls.USER,
            "password": cls.PASSWORD,
        }

    @classmethod
    def instance(cls) -> "Database":
        admins = None
        if not cls._INSTANCE:
            try:
                cls._INSTANCE = Database()
                if not userIsValid():
                    cls._INSTANCE = None
                    admins = gazetteerAdmins()
            except:
                msg = str(sys.exc_info()[1])
                raise RuntimeError(
                    "Current user "
                    + str(cls.USER)
                    + " is not authorized to access the gazetteer database.\n"
                    + msg
                )

        if not cls._INSTANCE:
            raise RuntimeError(
                "Current user "
                + str(cls.USER)
                + " is not authorized to access the gazetteer database\n"
                + "Contact a gazetteer admin:\n    "
                + "\n    ".join(admins)
            )

        return cls._INSTANCE


Database.update_connection_details()


def engine():
    return Database.instance().engine()


def session():
    return Database.instance().session()


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
