SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(32);

SELECT has_table(
    'gazetteer', 'name_association',
    'Should have table gazetteer.name_association'
);

SELECT has_pk(
    'gazetteer', 'name_association',
    'Table gazetteer.name_association should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'name_association'::name, ARRAY[
    'assoc_id'::name,
    'name_id_from'::name,
    'name_id_to'::name,
    'assoc_type'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer', 'name_association', 'assoc_id', 'Column gazetteer.name_association.assoc_id should exist');
SELECT col_type_is(      'gazetteer', 'name_association', 'assoc_id', 'integer', 'Column gazetteer.name_association.assoc_id should be type integer');
SELECT col_not_null(     'gazetteer', 'name_association', 'assoc_id', 'Column gazetteer.name_association.assoc_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'name_association', 'assoc_id', 'Column gazetteer.name_association.assoc_id should have a default');
SELECT col_default_is(   'gazetteer', 'name_association', 'assoc_id', 'nextval(''gazetteer.name_association_assoc_id_seq''::regclass)', 'Column gazetteer.name_association.assoc_id default is');

SELECT has_column(       'gazetteer', 'name_association', 'name_id_from', 'Column gazetteer.name_association.name_id_from should exist');
SELECT col_type_is(      'gazetteer', 'name_association', 'name_id_from', 'integer', 'Column gazetteer.name_association.name_id_from should be type integer');
SELECT col_not_null(     'gazetteer', 'name_association', 'name_id_from', 'Column gazetteer.name_association.name_id_from should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'name_association', 'name_id_from', 'Column gazetteer.name_association.name_id_from should not  have a default');

SELECT has_column(       'gazetteer', 'name_association', 'name_id_to', 'Column gazetteer.name_association.name_id_to should exist');
SELECT col_type_is(      'gazetteer', 'name_association', 'name_id_to', 'integer', 'Column gazetteer.name_association.name_id_to should be type integer');
SELECT col_not_null(     'gazetteer', 'name_association', 'name_id_to', 'Column gazetteer.name_association.name_id_to should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'name_association', 'name_id_to', 'Column gazetteer.name_association.name_id_to should not  have a default');

SELECT has_column(       'gazetteer', 'name_association', 'assoc_type', 'Column gazetteer.name_association.assoc_type should exist');
SELECT col_type_is(      'gazetteer', 'name_association', 'assoc_type', 'character(4)', 'Column gazetteer.name_association.assoc_type should be type character(4)');
SELECT col_not_null(     'gazetteer', 'name_association', 'assoc_type', 'Column gazetteer.name_association.assoc_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'name_association', 'assoc_type', 'Column gazetteer.name_association.assoc_type should not  have a default');

SELECT has_column(       'gazetteer', 'name_association', 'updated_by', 'Column gazetteer.name_association.updated_by should exist');
SELECT col_type_is(      'gazetteer', 'name_association', 'updated_by', 'name', 'Column gazetteer.name_association.updated_by should be type name');
SELECT col_is_null(      'gazetteer', 'name_association', 'updated_by', 'Column gazetteer.name_association.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_association', 'updated_by', 'Column gazetteer.name_association.updated_by should not  have a default');

SELECT has_column(       'gazetteer', 'name_association', 'update_date', 'Column gazetteer.name_association.update_date should exist');
SELECT col_type_is(      'gazetteer', 'name_association', 'update_date', 'timestamp without time zone', 'Column gazetteer.name_association.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'name_association', 'update_date', 'Column gazetteer.name_association.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_association', 'update_date', 'Column gazetteer.name_association.update_date should not  have a default');

SELECT has_trigger( 'gazetteer', 'name_association', 'trg_name_association_history'::name);
SELECT trigger_is(  'gazetteer', 'name_association', 'trg_name_association_history', 'gazetteer', 'trgfunc_name_association_history');
SELECT has_trigger( 'gazetteer', 'name_association', 'trg_name_association_update'::name);
SELECT trigger_is(  'gazetteer', 'name_association', 'trg_name_association_update', 'gazetteer', 'trgfunc_name_association_update');

SELECT * FROM finish();
ROLLBACK;
