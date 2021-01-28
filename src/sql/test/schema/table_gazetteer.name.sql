SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(36);

SELECT has_table(
    'gazetteer', 'name',
    'Should have table gazetteer.name'
);

SELECT has_pk(
    'gazetteer', 'name',
    'Table gazetteer.name should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'name'::name, ARRAY[
    'name_id'::name,
    'feat_id'::name,
    'name'::name,
    'process'::name,
    'status'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer', 'name', 'name_id', 'Column gazetteer.name.name_id should exist');
SELECT col_type_is(      'gazetteer', 'name', 'name_id', 'integer', 'Column gazetteer.name.name_id should be type integer');
SELECT col_not_null(     'gazetteer', 'name', 'name_id', 'Column gazetteer.name.name_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'name', 'name_id', 'Column gazetteer.name.name_id should have a default');
SELECT col_default_is(   'gazetteer', 'name', 'name_id', 'nextval(''gazetteer.name_name_id_seq''::regclass)', 'Column gazetteer.name.name_id default is');

SELECT has_column(       'gazetteer', 'name', 'feat_id', 'Column gazetteer.name.feat_id should exist');
SELECT col_type_is(      'gazetteer', 'name', 'feat_id', 'integer', 'Column gazetteer.name.feat_id should be type integer');
SELECT col_not_null(     'gazetteer', 'name', 'feat_id', 'Column gazetteer.name.feat_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'name', 'feat_id', 'Column gazetteer.name.feat_id should not  have a default');

SELECT has_column(       'gazetteer', 'name', 'name', 'Column gazetteer.name.name should exist');
SELECT col_type_is(      'gazetteer', 'name', 'name', 'character varying(1024)', 'Column gazetteer.name.name should be type character varying(1024)');
SELECT col_is_null(      'gazetteer', 'name', 'name', 'Column gazetteer.name.name should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name', 'name', 'Column gazetteer.name.name should not  have a default');

SELECT has_column(       'gazetteer', 'name', 'process', 'Column gazetteer.name.process should exist');
SELECT col_type_is(      'gazetteer', 'name', 'process', 'character(4)', 'Column gazetteer.name.process should be type character(4)');
SELECT col_is_null(      'gazetteer', 'name', 'process', 'Column gazetteer.name.process should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name', 'process', 'Column gazetteer.name.process should not  have a default');

SELECT has_column(       'gazetteer', 'name', 'status', 'Column gazetteer.name.status should exist');
SELECT col_type_is(      'gazetteer', 'name', 'status', 'character(4)', 'Column gazetteer.name.status should be type character(4)');
SELECT col_is_null(      'gazetteer', 'name', 'status', 'Column gazetteer.name.status should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name', 'status', 'Column gazetteer.name.status should not  have a default');

SELECT has_column(       'gazetteer', 'name', 'updated_by', 'Column gazetteer.name.updated_by should exist');
SELECT col_type_is(      'gazetteer', 'name', 'updated_by', 'name', 'Column gazetteer.name.updated_by should be type name');
SELECT col_is_null(      'gazetteer', 'name', 'updated_by', 'Column gazetteer.name.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name', 'updated_by', 'Column gazetteer.name.updated_by should not  have a default');

SELECT has_column(       'gazetteer', 'name', 'update_date', 'Column gazetteer.name.update_date should exist');
SELECT col_type_is(      'gazetteer', 'name', 'update_date', 'timestamp without time zone', 'Column gazetteer.name.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'name', 'update_date', 'Column gazetteer.name.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name', 'update_date', 'Column gazetteer.name.update_date should not  have a default');

SELECT has_trigger( 'gazetteer', 'name', 'trg_name_history'::name);
SELECT trigger_is(  'gazetteer', 'name', 'trg_name_history', 'gazetteer', 'trgfunc_name_history');
SELECT has_trigger( 'gazetteer', 'name', 'trg_name_update'::name);
SELECT trigger_is(  'gazetteer', 'name', 'trg_name_update', 'gazetteer', 'trgfunc_name_update');

SELECT * FROM finish();
ROLLBACK;
