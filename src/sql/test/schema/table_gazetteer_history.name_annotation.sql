SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(44);

SELECT has_table(
    'gazetteer_history', 'name_annotation',
    'Should have table gazetteer_history.name_annotation'
);

SELECT has_pk(
    'gazetteer_history', 'name_annotation',
    'Table gazetteer_history.name_annotation should have a primary key'
);

SELECT columns_are('gazetteer_history'::name, 'name_annotation'::name, ARRAY[
    'history_id'::name,
    'history_date'::name,
    'history_user'::name,
    'history_action'::name,
    'annot_id'::name,
    'name_id'::name,
    'annotation_type'::name,
    'annotation'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer_history', 'name_annotation', 'history_id', 'Column gazetteer_history.name_annotation.history_id should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'history_id', 'integer', 'Column gazetteer_history.name_annotation.history_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'name_annotation', 'history_id', 'Column gazetteer_history.name_annotation.history_id should be NOT NULL');
SELECT col_has_default(  'gazetteer_history', 'name_annotation', 'history_id', 'Column gazetteer_history.name_annotation.history_id should have a default');
SELECT col_default_is(   'gazetteer_history', 'name_annotation', 'history_id', 'nextval(''gazetteer_history.name_annotation_history_id_seq''::regclass)', 'Column gazetteer_history.name_annotation.history_id default is');

SELECT has_column(       'gazetteer_history', 'name_annotation', 'history_date', 'Column gazetteer_history.name_annotation.history_date should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'history_date', 'timestamp without time zone', 'Column gazetteer_history.name_annotation.history_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'name_annotation', 'history_date', 'Column gazetteer_history.name_annotation.history_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name_annotation', 'history_date', 'Column gazetteer_history.name_annotation.history_date should not  have a default');

SELECT has_column(       'gazetteer_history', 'name_annotation', 'history_user', 'Column gazetteer_history.name_annotation.history_user should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'history_user', 'name', 'Column gazetteer_history.name_annotation.history_user should be type name');
SELECT col_is_null(      'gazetteer_history', 'name_annotation', 'history_user', 'Column gazetteer_history.name_annotation.history_user should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name_annotation', 'history_user', 'Column gazetteer_history.name_annotation.history_user should not  have a default');

SELECT has_column(       'gazetteer_history', 'name_annotation', 'history_action', 'Column gazetteer_history.name_annotation.history_action should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'history_action', 'character(1)', 'Column gazetteer_history.name_annotation.history_action should be type character(1)');
SELECT col_is_null(      'gazetteer_history', 'name_annotation', 'history_action', 'Column gazetteer_history.name_annotation.history_action should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name_annotation', 'history_action', 'Column gazetteer_history.name_annotation.history_action should not  have a default');

SELECT has_column(       'gazetteer_history', 'name_annotation', 'annot_id', 'Column gazetteer_history.name_annotation.annot_id should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'annot_id', 'integer', 'Column gazetteer_history.name_annotation.annot_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'name_annotation', 'annot_id', 'Column gazetteer_history.name_annotation.annot_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'name_annotation', 'annot_id', 'Column gazetteer_history.name_annotation.annot_id should not  have a default');

SELECT has_column(       'gazetteer_history', 'name_annotation', 'name_id', 'Column gazetteer_history.name_annotation.name_id should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'name_id', 'integer', 'Column gazetteer_history.name_annotation.name_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'name_annotation', 'name_id', 'Column gazetteer_history.name_annotation.name_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'name_annotation', 'name_id', 'Column gazetteer_history.name_annotation.name_id should not  have a default');

SELECT has_column(       'gazetteer_history', 'name_annotation', 'annotation_type', 'Column gazetteer_history.name_annotation.annotation_type should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'annotation_type', 'character(4)', 'Column gazetteer_history.name_annotation.annotation_type should be type character(4)');
SELECT col_not_null(     'gazetteer_history', 'name_annotation', 'annotation_type', 'Column gazetteer_history.name_annotation.annotation_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'name_annotation', 'annotation_type', 'Column gazetteer_history.name_annotation.annotation_type should not  have a default');

SELECT has_column(       'gazetteer_history', 'name_annotation', 'annotation', 'Column gazetteer_history.name_annotation.annotation should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'annotation', 'text', 'Column gazetteer_history.name_annotation.annotation should be type text');
SELECT col_is_null(      'gazetteer_history', 'name_annotation', 'annotation', 'Column gazetteer_history.name_annotation.annotation should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name_annotation', 'annotation', 'Column gazetteer_history.name_annotation.annotation should not  have a default');

SELECT has_column(       'gazetteer_history', 'name_annotation', 'updated_by', 'Column gazetteer_history.name_annotation.updated_by should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'updated_by', 'name', 'Column gazetteer_history.name_annotation.updated_by should be type name');
SELECT col_is_null(      'gazetteer_history', 'name_annotation', 'updated_by', 'Column gazetteer_history.name_annotation.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name_annotation', 'updated_by', 'Column gazetteer_history.name_annotation.updated_by should not  have a default');

SELECT has_column(       'gazetteer_history', 'name_annotation', 'update_date', 'Column gazetteer_history.name_annotation.update_date should exist');
SELECT col_type_is(      'gazetteer_history', 'name_annotation', 'update_date', 'timestamp without time zone', 'Column gazetteer_history.name_annotation.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'name_annotation', 'update_date', 'Column gazetteer_history.name_annotation.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'name_annotation', 'update_date', 'Column gazetteer_history.name_annotation.update_date should not  have a default');

SELECT * FROM finish();
ROLLBACK;
