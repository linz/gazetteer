SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(48);

SELECT has_table(
    'gazetteer_history', 'name',
    'Should have table gazetteer_history.name'
);

SELECT has_pk(
    'gazetteer_history', 'name',
    'Table gazetteer_history.name should have a primary key'
);

SELECT columns_are('gazetteer_history'::name, 'name'::name, ARRAY[
    'history_id'::name,
    'history_date'::name,
    'history_user'::name,
    'history_action'::name,
    'name_id'::name,
    'feat_id'::name,
    'name'::name,
    'process'::name,
    'status'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer_history', 'name', 'history_id', 'Column gazetteer_history.name.history_id should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'history_id', 'integer', 'Column gazetteer_history.name.history_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'name', 'history_id', 'Column gazetteer_history.name.history_id should be NOT NULL');
SELECT col_has_default(  'gazetteer_history', 'name', 'history_id', 'Column gazetteer_history.name.history_id should have a default');
SELECT col_default_is(   'gazetteer_history', 'name', 'history_id', 'nextval(''gazetteer_history.name_history_id_seq''::regclass)', 'Column gazetteer_history.name.history_id default is');

SELECT has_column(       'gazetteer_history', 'name', 'history_date', 'Column gazetteer_history.name.history_date should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'history_date', 'timestamp without time zone', 'Column gazetteer_history.name.history_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'name', 'history_date', 'Column gazetteer_history.name.history_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'history_date', 'Column gazetteer_history.name.history_date should not  have a default');

SELECT has_column(       'gazetteer_history', 'name', 'history_user', 'Column gazetteer_history.name.history_user should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'history_user', 'name', 'Column gazetteer_history.name.history_user should be type name');
SELECT col_is_null(      'gazetteer_history', 'name', 'history_user', 'Column gazetteer_history.name.history_user should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'history_user', 'Column gazetteer_history.name.history_user should not  have a default');

SELECT has_column(       'gazetteer_history', 'name', 'history_action', 'Column gazetteer_history.name.history_action should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'history_action', 'character(1)', 'Column gazetteer_history.name.history_action should be type character(1)');
SELECT col_is_null(      'gazetteer_history', 'name', 'history_action', 'Column gazetteer_history.name.history_action should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'history_action', 'Column gazetteer_history.name.history_action should not  have a default');

SELECT has_column(       'gazetteer_history', 'name', 'name_id', 'Column gazetteer_history.name.name_id should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'name_id', 'integer', 'Column gazetteer_history.name.name_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'name', 'name_id', 'Column gazetteer_history.name.name_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'name_id', 'Column gazetteer_history.name.name_id should not  have a default');

SELECT has_column(       'gazetteer_history', 'name', 'feat_id', 'Column gazetteer_history.name.feat_id should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'feat_id', 'integer', 'Column gazetteer_history.name.feat_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'name', 'feat_id', 'Column gazetteer_history.name.feat_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'feat_id', 'Column gazetteer_history.name.feat_id should not  have a default');

SELECT has_column(       'gazetteer_history', 'name', 'name', 'Column gazetteer_history.name.name should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'name', 'character varying(1024)', 'Column gazetteer_history.name.name should be type character varying(1024)');
SELECT col_is_null(      'gazetteer_history', 'name', 'name', 'Column gazetteer_history.name.name should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'name', 'Column gazetteer_history.name.name should not  have a default');

SELECT has_column(       'gazetteer_history', 'name', 'process', 'Column gazetteer_history.name.process should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'process', 'character(4)', 'Column gazetteer_history.name.process should be type character(4)');
SELECT col_is_null(      'gazetteer_history', 'name', 'process', 'Column gazetteer_history.name.process should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'process', 'Column gazetteer_history.name.process should not  have a default');

SELECT has_column(       'gazetteer_history', 'name', 'status', 'Column gazetteer_history.name.status should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'status', 'character(4)', 'Column gazetteer_history.name.status should be type character(4)');
SELECT col_is_null(      'gazetteer_history', 'name', 'status', 'Column gazetteer_history.name.status should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'status', 'Column gazetteer_history.name.status should not  have a default');

SELECT has_column(       'gazetteer_history', 'name', 'updated_by', 'Column gazetteer_history.name.updated_by should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'updated_by', 'name', 'Column gazetteer_history.name.updated_by should be type name');
SELECT col_is_null(      'gazetteer_history', 'name', 'updated_by', 'Column gazetteer_history.name.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'updated_by', 'Column gazetteer_history.name.updated_by should not  have a default');

SELECT has_column(       'gazetteer_history', 'name', 'update_date', 'Column gazetteer_history.name.update_date should exist');
SELECT col_type_is(      'gazetteer_history', 'name', 'update_date', 'timestamp without time zone', 'Column gazetteer_history.name.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'name', 'update_date', 'Column gazetteer_history.name.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name', 'update_date', 'Column gazetteer_history.name.update_date should not  have a default');

SELECT * FROM finish();
ROLLBACK;
