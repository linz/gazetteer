SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(32);

SELECT has_table(
    'gazetteer', 'name_annotation',
    'Should have table gazetteer.name_annotation'
);

SELECT has_pk(
    'gazetteer', 'name_annotation',
    'Table gazetteer.name_annotation should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'name_annotation'::name, ARRAY[
    'annot_id'::name,
    'name_id'::name,
    'annotation_type'::name,
    'annotation'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer', 'name_annotation', 'annot_id', 'Column gazetteer.name_annotation.annot_id should exist');
SELECT col_type_is(      'gazetteer', 'name_annotation', 'annot_id', 'integer', 'Column gazetteer.name_annotation.annot_id should be type integer');
SELECT col_not_null(     'gazetteer', 'name_annotation', 'annot_id', 'Column gazetteer.name_annotation.annot_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'name_annotation', 'annot_id', 'Column gazetteer.name_annotation.annot_id should have a default');
SELECT col_default_is(   'gazetteer', 'name_annotation', 'annot_id', 'nextval(''gazetteer.name_annotation_annot_id_seq''::regclass)', 'Column gazetteer.name_annotation.annot_id default is');

SELECT has_column(       'gazetteer', 'name_annotation', 'name_id', 'Column gazetteer.name_annotation.name_id should exist');
SELECT col_type_is(      'gazetteer', 'name_annotation', 'name_id', 'integer', 'Column gazetteer.name_annotation.name_id should be type integer');
SELECT col_not_null(     'gazetteer', 'name_annotation', 'name_id', 'Column gazetteer.name_annotation.name_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'name_annotation', 'name_id', 'Column gazetteer.name_annotation.name_id should not  have a default');

SELECT has_column(       'gazetteer', 'name_annotation', 'annotation_type', 'Column gazetteer.name_annotation.annotation_type should exist');
SELECT col_type_is(      'gazetteer', 'name_annotation', 'annotation_type', 'character(4)', 'Column gazetteer.name_annotation.annotation_type should be type character(4)');
SELECT col_not_null(     'gazetteer', 'name_annotation', 'annotation_type', 'Column gazetteer.name_annotation.annotation_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'name_annotation', 'annotation_type', 'Column gazetteer.name_annotation.annotation_type should not  have a default');

SELECT has_column(       'gazetteer', 'name_annotation', 'annotation', 'Column gazetteer.name_annotation.annotation should exist');
SELECT col_type_is(      'gazetteer', 'name_annotation', 'annotation', 'text', 'Column gazetteer.name_annotation.annotation should be type text');
SELECT col_is_null(      'gazetteer', 'name_annotation', 'annotation', 'Column gazetteer.name_annotation.annotation should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_annotation', 'annotation', 'Column gazetteer.name_annotation.annotation should not  have a default');

SELECT has_column(       'gazetteer', 'name_annotation', 'updated_by', 'Column gazetteer.name_annotation.updated_by should exist');
SELECT col_type_is(      'gazetteer', 'name_annotation', 'updated_by', 'name', 'Column gazetteer.name_annotation.updated_by should be type name');
SELECT col_is_null(      'gazetteer', 'name_annotation', 'updated_by', 'Column gazetteer.name_annotation.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_annotation', 'updated_by', 'Column gazetteer.name_annotation.updated_by should not  have a default');

SELECT has_column(       'gazetteer', 'name_annotation', 'update_date', 'Column gazetteer.name_annotation.update_date should exist');
SELECT col_type_is(      'gazetteer', 'name_annotation', 'update_date', 'timestamp without time zone', 'Column gazetteer.name_annotation.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'name_annotation', 'update_date', 'Column gazetteer.name_annotation.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_annotation', 'update_date', 'Column gazetteer.name_annotation.update_date should not  have a default');

SELECT has_trigger( 'gazetteer', 'name_annotation', 'trg_name_annotation_history'::name);
SELECT trigger_is(  'gazetteer', 'name_annotation', 'trg_name_annotation_history', 'gazetteer', 'trgfunc_name_annotation_history');
SELECT has_trigger( 'gazetteer', 'name_annotation', 'trg_name_annotation_update'::name);
SELECT trigger_is(  'gazetteer', 'name_annotation', 'trg_name_annotation_update', 'gazetteer', 'trgfunc_name_annotation_update');

SELECT * FROM finish();
ROLLBACK;
