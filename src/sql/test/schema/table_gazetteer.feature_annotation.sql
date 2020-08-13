SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(32);

SELECT has_table(
    'gazetteer', 'feature_annotation',
    'Should have table gazetteer.feature_annotation'
);

SELECT has_pk(
    'gazetteer', 'feature_annotation',
    'Table gazetteer.feature_annotation should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'feature_annotation'::name, ARRAY[
    'annot_id'::name,
    'feat_id'::name,
    'annotation_type'::name,
    'annotation'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer', 'feature_annotation', 'annot_id', 'Column gazetteer.feature_annotation.annot_id should exist');
SELECT col_type_is(      'gazetteer', 'feature_annotation', 'annot_id', 'integer', 'Column gazetteer.feature_annotation.annot_id should be type integer');
SELECT col_not_null(     'gazetteer', 'feature_annotation', 'annot_id', 'Column gazetteer.feature_annotation.annot_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'feature_annotation', 'annot_id', 'Column gazetteer.feature_annotation.annot_id should have a default');
SELECT col_default_is(   'gazetteer', 'feature_annotation', 'annot_id', 'nextval(''gazetteer.feature_annotation_annot_id_seq''::regclass)', 'Column gazetteer.feature_annotation.annot_id default is');

SELECT has_column(       'gazetteer', 'feature_annotation', 'feat_id', 'Column gazetteer.feature_annotation.feat_id should exist');
SELECT col_type_is(      'gazetteer', 'feature_annotation', 'feat_id', 'integer', 'Column gazetteer.feature_annotation.feat_id should be type integer');
SELECT col_not_null(     'gazetteer', 'feature_annotation', 'feat_id', 'Column gazetteer.feature_annotation.feat_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature_annotation', 'feat_id', 'Column gazetteer.feature_annotation.feat_id should not  have a default');

SELECT has_column(       'gazetteer', 'feature_annotation', 'annotation_type', 'Column gazetteer.feature_annotation.annotation_type should exist');
SELECT col_type_is(      'gazetteer', 'feature_annotation', 'annotation_type', 'character(4)', 'Column gazetteer.feature_annotation.annotation_type should be type character(4)');
SELECT col_not_null(     'gazetteer', 'feature_annotation', 'annotation_type', 'Column gazetteer.feature_annotation.annotation_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature_annotation', 'annotation_type', 'Column gazetteer.feature_annotation.annotation_type should not  have a default');

SELECT has_column(       'gazetteer', 'feature_annotation', 'annotation', 'Column gazetteer.feature_annotation.annotation should exist');
SELECT col_type_is(      'gazetteer', 'feature_annotation', 'annotation', 'text', 'Column gazetteer.feature_annotation.annotation should be type text');
SELECT col_is_null(      'gazetteer', 'feature_annotation', 'annotation', 'Column gazetteer.feature_annotation.annotation should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature_annotation', 'annotation', 'Column gazetteer.feature_annotation.annotation should not  have a default');

SELECT has_column(       'gazetteer', 'feature_annotation', 'updated_by', 'Column gazetteer.feature_annotation.updated_by should exist');
SELECT col_type_is(      'gazetteer', 'feature_annotation', 'updated_by', 'name', 'Column gazetteer.feature_annotation.updated_by should be type name');
SELECT col_is_null(      'gazetteer', 'feature_annotation', 'updated_by', 'Column gazetteer.feature_annotation.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature_annotation', 'updated_by', 'Column gazetteer.feature_annotation.updated_by should not  have a default');

SELECT has_column(       'gazetteer', 'feature_annotation', 'update_date', 'Column gazetteer.feature_annotation.update_date should exist');
SELECT col_type_is(      'gazetteer', 'feature_annotation', 'update_date', 'timestamp without time zone', 'Column gazetteer.feature_annotation.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'feature_annotation', 'update_date', 'Column gazetteer.feature_annotation.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature_annotation', 'update_date', 'Column gazetteer.feature_annotation.update_date should not  have a default');

SELECT has_trigger( 'gazetteer', 'feature_annotation', 'trg_feature_annotation_history'::name);
SELECT trigger_is(  'gazetteer', 'feature_annotation', 'trg_feature_annotation_history', 'gazetteer', 'trgfunc_feature_annotation_history');
SELECT has_trigger( 'gazetteer', 'feature_annotation', 'trg_feature_annotation_update'::name);
SELECT trigger_is(  'gazetteer', 'feature_annotation', 'trg_feature_annotation_update', 'gazetteer', 'trgfunc_feature_annotation_update');

SELECT * FROM finish();
ROLLBACK;
