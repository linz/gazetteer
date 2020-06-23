import os
import json


from .database import Database


class TestDataHandler:
    """
    Manager the loading and querying of test data
    """

    def __init__(self, data_file=None):
        self.db = Database()
        self.table_sys_code = "gazetteer.system_code"
        self.data = self.read_test_data(data_file)

    def read_test_data(self, data_file):
        """
        Read test data from json file
        """
        # either provide a file else it is read from
        # ../data/data.json
        if not data_file:
            data_file = os.path.join(
                os.path.dirname(__file__), "../data/test_data.json"
            )

            with open(data_file) as f:
                return json.load(f)

    def insert_sys_codes(self):
        """
        Add the sys_codes to the NZGB database required to perform
        the automated tests.
        """

        for codes in self.data[self.table_sys_code]:
            insert_statement = f"INSERT INTO {self.table_sys_code} VALUES ('{codes['code_group']}', '{codes['code']}','{codes['category']}', '{codes['value']}', '{codes['description']}', '{codes['updated_by']}', '{codes['update_date']}')"
            self.db.execute(insert_statement)

    def delete_sys_codes(self):
        """
        Remove the sys_codes to the NZGB database required to perform
        the automated tests.
        """

        for codes in self.data[self.table_sys_code]:
            delete_statement = f"""
                DELETE
                FROM {self.table_sys_code}
                WHERE   code_group = '{codes['code_group']}'
                AND     code = '{codes['code']}'
            """
            self.db.execute(delete_statement)

    def last_added_feature(self):
        """
        Using the PK get the last featured add to the DB
        """

        last_added_feature_statement = f"""
            SELECT name_id, feat_id, name, process, status, updated_by, update_date
            FROM gazetteer.name
            ORDER BY feat_id DESC
            LIMIT 1
            """
        return self.db.select(last_added_feature_statement)

    def get_feature_by_id(self, name_id):
        """
        Get database feature by name
        """

        last_added_feature_statement = f"""
            SELECT name_id, feat_id, name, process, status, updated_by, update_date
            FROM gazetteer.name
            WHERE name_id = '{name_id}'
            ORDER BY feat_id DESC
            """
        return self.db.select(last_added_feature_statement)
