SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(35);

SELECT has_table(
    'gazetteer', 'system_code',
    'Should have table gazetteer.system_code'
);

SELECT has_pk(
    'gazetteer', 'system_code',
    'Table gazetteer.system_code should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'system_code'::name, ARRAY[
    'code_group'::name,
    'code'::name,
    'category'::name,
    'value'::name,
    'description'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer', 'system_code', 'code_group', 'Column gazetteer.system_code.code_group should exist');
SELECT col_type_is(      'gazetteer', 'system_code', 'code_group', 'character(4)', 'Column gazetteer.system_code.code_group should be type character(4)');
SELECT col_not_null(     'gazetteer', 'system_code', 'code_group', 'Column gazetteer.system_code.code_group should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'system_code', 'code_group', 'Column gazetteer.system_code.code_group should not  have a default');

SELECT has_column(       'gazetteer', 'system_code', 'code', 'Column gazetteer.system_code.code should exist');
SELECT col_type_is(      'gazetteer', 'system_code', 'code', 'character(4)', 'Column gazetteer.system_code.code should be type character(4)');
SELECT col_not_null(     'gazetteer', 'system_code', 'code', 'Column gazetteer.system_code.code should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'system_code', 'code', 'Column gazetteer.system_code.code should not  have a default');

SELECT has_column(       'gazetteer', 'system_code', 'category', 'Column gazetteer.system_code.category should exist');
SELECT col_type_is(      'gazetteer', 'system_code', 'category', 'character(4)', 'Column gazetteer.system_code.category should be type character(4)');
SELECT col_is_null(      'gazetteer', 'system_code', 'category', 'Column gazetteer.system_code.category should allow NULL');
SELECT col_hasnt_default('gazetteer', 'system_code', 'category', 'Column gazetteer.system_code.category should not  have a default');

SELECT has_column(       'gazetteer', 'system_code', 'value', 'Column gazetteer.system_code.value should exist');
SELECT col_type_is(      'gazetteer', 'system_code', 'value', 'character varying(255)', 'Column gazetteer.system_code.value should be type character varying(255)');
SELECT col_not_null(     'gazetteer', 'system_code', 'value', 'Column gazetteer.system_code.value should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'system_code', 'value', 'Column gazetteer.system_code.value should not  have a default');

SELECT has_column(       'gazetteer', 'system_code', 'description', 'Column gazetteer.system_code.description should exist');
SELECT col_type_is(      'gazetteer', 'system_code', 'description', 'text', 'Column gazetteer.system_code.description should be type text');
SELECT col_is_null(      'gazetteer', 'system_code', 'description', 'Column gazetteer.system_code.description should allow NULL');
SELECT col_hasnt_default('gazetteer', 'system_code', 'description', 'Column gazetteer.system_code.description should not  have a default');

SELECT has_column(       'gazetteer', 'system_code', 'updated_by', 'Column gazetteer.system_code.updated_by should exist');
SELECT col_type_is(      'gazetteer', 'system_code', 'updated_by', 'name', 'Column gazetteer.system_code.updated_by should be type name');
SELECT col_is_null(      'gazetteer', 'system_code', 'updated_by', 'Column gazetteer.system_code.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer', 'system_code', 'updated_by', 'Column gazetteer.system_code.updated_by should not  have a default');

SELECT has_column(       'gazetteer', 'system_code', 'update_date', 'Column gazetteer.system_code.update_date should exist');
SELECT col_type_is(      'gazetteer', 'system_code', 'update_date', 'timestamp without time zone', 'Column gazetteer.system_code.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'system_code', 'update_date', 'Column gazetteer.system_code.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'system_code', 'update_date', 'Column gazetteer.system_code.update_date should not  have a default');

SELECT has_trigger( 'gazetteer', 'system_code', 'trg_system_code_history'::name);
SELECT trigger_is(  'gazetteer', 'system_code', 'trg_system_code_history', 'gazetteer', 'trgfunc_system_code_history');
SELECT has_trigger( 'gazetteer', 'system_code', 'trg_system_code_update'::name);
SELECT trigger_is(  'gazetteer', 'system_code', 'trg_system_code_update', 'gazetteer', 'trgfunc_system_code_update');

SELECT * FROM finish();
ROLLBACK;
