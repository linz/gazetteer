from . import database
import os
import json


class TestDataHandler:
    def __init__(self, data_file=None):
        self.db = database.Database()
        self.table_sys_code = "gazetteer.system_code"
        self.data = self.read_test_data(data_file)

    def read_test_data(self, data_file):
        # either provide a file else it is read from
        # ../data/data.json
        if not data_file:
            data_file = os.path.join(
                os.path.dirname(__file__), "../data/test_data.json"
            )

            with open(data_file) as f:
                return json.load(f)

    def insert_sys_codes(self):

        for codes in self.data[self.table_sys_code]:
            insert_statement = f"INSERT INTO {self.table_sys_code} VALUES ('{codes['code_group']}', '{codes['code']}','{codes['category']}', '{codes['value']}', '{codes['updated_by']}', '{codes['update_date']}')"
            self.db.execute_query(insert_statement)

    def delete_sys_codes(self):

        for codes in self.data[self.table_sys_code]:
            delete_statement = f"""
                DELETE 
                FROM {self.table_sys_code} 
                WHERE   code_group = '{codes['code_group']}'
                AND     code = '{codes['code']}'
            """
            self.db.execute_query(delete_statement)


util = TestDataHandler()
util.insert_sys_codes()
util.delete_sys_codes()
