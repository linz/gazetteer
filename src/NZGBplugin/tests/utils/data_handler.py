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

    def get_name_by_id(self, name_id):
        """
        Get database name by id
        """

        names = f"""
            SELECT name_id, feat_id, name, process, status, updated_by, update_date
            FROM gazetteer.name
            WHERE name_id = '{name_id}'
            ORDER BY name_id DESC
            """

        return self.db.select(names)

    def get_feature_by_id(self, feat_id):
        """
        Get database feature by name
        """

        features = f"""
            SELECT feat_id, feat_type, status, description, updated_by, update_date,ref_point
            FROM gazetteer.feature
            WHERE feat_id = '{feat_id}'
            ORDER BY feat_id DESC
            """

        return self.db.select(features)

    def get_feat_annotation_by_id(self, feat_id):
        """
        Get database feature by name
        """

        annotations = f"""
        SELECT annot_id, feat_id, annotation_type, annotation, updated_by, update_date
        FROM gazetteer.feature_annotation
        WHERE feat_id = '{feat_id}'
        ORDER BY  feat_id DESC
        """

        return self.db.select(annotations)

    def get_event_by_id(self, name_id):
        """
        Get database event record by name
        """

        events = f"""
        SELECT event_id, name_id, event_date, event_type, authority, event_reference,
        notes, updated_by, update_date
        FROM gazetteer.name_event
        WHERE name_id = '{name_id}'
        """

        return self.db.select(events)

    def get_name_annotation_by_id(self, name_id):
        """
        Get database name annotation record
        """

        annotations = f"""
        SELECT annot_id, name_id, annotation_type, annotation, updated_by, update_date
        FROM gazetteer.name_annotation
        WHERE name_id = '{name_id}'
        ORDER BY  name_id DESC
        """

        return self.db.select(annotations)

    def get_feat_association_by_id(self, feat_id):
        """
        Get database name association record
        """

        association = f"""
        SELECT assoc_id, feat_id_from, feat_id_to, assoc_type, updated_by, update_date
        FROM gazetteer.feature_association
        WHERE feat_id_from = '{feat_id}'
        ORDER BY  assoc_id DESC
        """

        return self.db.select(association)
