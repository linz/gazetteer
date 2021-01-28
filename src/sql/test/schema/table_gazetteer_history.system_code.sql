SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(48);

SELECT has_table(
    'gazetteer_history', 'system_code',
    'Should have table gazetteer_history.system_code'
);

SELECT has_pk(
    'gazetteer_history', 'system_code',
    'Table gazetteer_history.system_code should have a primary key'
);

SELECT columns_are('gazetteer_history'::name, 'system_code'::name, ARRAY[
    'history_id'::name,
    'history_date'::name,
    'history_user'::name,
    'history_action'::name,
    'code_group'::name,
    'code'::name,
    'category'::name,
    'value'::name,
    'description'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer_history', 'system_code', 'history_id', 'Column gazetteer_history.system_code.history_id should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'history_id', 'integer', 'Column gazetteer_history.system_code.history_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'system_code', 'history_id', 'Column gazetteer_history.system_code.history_id should be NOT NULL');
SELECT col_has_default(  'gazetteer_history', 'system_code', 'history_id', 'Column gazetteer_history.system_code.history_id should have a default');
SELECT col_default_is(   'gazetteer_history', 'system_code', 'history_id', 'nextval(''gazetteer_history.system_code_history_id_seq''::regclass)', 'Column gazetteer_history.system_code.history_id default is');

SELECT has_column(       'gazetteer_history', 'system_code', 'history_date', 'Column gazetteer_history.system_code.history_date should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'history_date', 'timestamp without time zone', 'Column gazetteer_history.system_code.history_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'system_code', 'history_date', 'Column gazetteer_history.system_code.history_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'history_date', 'Column gazetteer_history.system_code.history_date should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'history_user', 'Column gazetteer_history.system_code.history_user should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'history_user', 'name', 'Column gazetteer_history.system_code.history_user should be type name');
SELECT col_is_null(      'gazetteer_history', 'system_code', 'history_user', 'Column gazetteer_history.system_code.history_user should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'history_user', 'Column gazetteer_history.system_code.history_user should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'history_action', 'Column gazetteer_history.system_code.history_action should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'history_action', 'character(1)', 'Column gazetteer_history.system_code.history_action should be type character(1)');
SELECT col_is_null(      'gazetteer_history', 'system_code', 'history_action', 'Column gazetteer_history.system_code.history_action should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'history_action', 'Column gazetteer_history.system_code.history_action should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'code_group', 'Column gazetteer_history.system_code.code_group should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'code_group', 'character(4)', 'Column gazetteer_history.system_code.code_group should be type character(4)');
SELECT col_not_null(     'gazetteer_history', 'system_code', 'code_group', 'Column gazetteer_history.system_code.code_group should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'code_group', 'Column gazetteer_history.system_code.code_group should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'code', 'Column gazetteer_history.system_code.code should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'code', 'character(4)', 'Column gazetteer_history.system_code.code should be type character(4)');
SELECT col_not_null(     'gazetteer_history', 'system_code', 'code', 'Column gazetteer_history.system_code.code should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'code', 'Column gazetteer_history.system_code.code should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'category', 'Column gazetteer_history.system_code.category should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'category', 'character(4)', 'Column gazetteer_history.system_code.category should be type character(4)');
SELECT col_is_null(      'gazetteer_history', 'system_code', 'category', 'Column gazetteer_history.system_code.category should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'category', 'Column gazetteer_history.system_code.category should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'value', 'Column gazetteer_history.system_code.value should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'value', 'character varying(255)', 'Column gazetteer_history.system_code.value should be type character varying(255)');
SELECT col_not_null(     'gazetteer_history', 'system_code', 'value', 'Column gazetteer_history.system_code.value should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'value', 'Column gazetteer_history.system_code.value should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'description', 'Column gazetteer_history.system_code.description should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'description', 'text', 'Column gazetteer_history.system_code.description should be type text');
SELECT col_is_null(      'gazetteer_history', 'system_code', 'description', 'Column gazetteer_history.system_code.description should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'description', 'Column gazetteer_history.system_code.description should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'updated_by', 'Column gazetteer_history.system_code.updated_by should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'updated_by', 'name', 'Column gazetteer_history.system_code.updated_by should be type name');
SELECT col_is_null(      'gazetteer_history', 'system_code', 'updated_by', 'Column gazetteer_history.system_code.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'updated_by', 'Column gazetteer_history.system_code.updated_by should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'update_date', 'Column gazetteer_history.system_code.update_date should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'update_date', 'timestamp without time zone', 'Column gazetteer_history.system_code.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'system_code', 'update_date', 'Column gazetteer_history.system_code.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'update_date', 'Column gazetteer_history.system_code.update_date should not  have a default');

SELECT * FROM finish();
ROLLBACK;
