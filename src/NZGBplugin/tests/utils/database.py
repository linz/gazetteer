import os
import psycopg2
from psycopg2 import Error

import configparser
import sys


class Database:
    """PostgreSQL Database class."""

    def __init__(self):
        config = configparser.ConfigParser()
        config_path = os.path.join(os.path.dirname(__file__), "config.ini")
        config.read(config_path)
        self.host = config["DB"]["HOST"]
        self.username = config["DB"]["USER"]
        self.password = config["DB"]["PASSWORD"]
        self.port = config["DB"]["PORT"]
        self.dbname = config["DB"]["DATABASE"]
        self.conn = None

    def connect(self):
        """Connect to a Postgres database."""
        if self.conn is None:
            try:
                self.conn = psycopg2.connect(
                    host=self.host,
                    user=self.username,
                    password=self.password,
                    port=self.port,
                    dbname=self.dbname,
                )
            except psycopg2.DatabaseError as error:
                sys.exit()

    def update(self, statement):
        """
        
        """

        self.connect()
        try:
            with self.conn.cursor() as cur:
                cur.execute(statement)
                self.conn.commit()
                cur.close()
                return f"{cur.rowcount} rows affected."

        except psycopg2.IntegrityError as error:
            # The record is already in the DB
            self.conn.rollback()
            print(error.pgerror)

    def select(self, statement):
        """
        So far there is only a need to select one row.
        ... this may change

        """

        self.connect()
        try:
            with self.conn.cursor() as cur:
                cur.execute(statement)
                self.conn.commit()
                row = cur.fetchone()
                cur.close()
                return row

        except psycopg2.Error as error:
            print(error.pgerror)
