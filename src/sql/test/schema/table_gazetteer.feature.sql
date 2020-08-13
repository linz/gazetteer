SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(36);

SELECT has_table(
    'gazetteer', 'feature',
    'Should have table gazetteer.feature'
);

SELECT has_pk(
    'gazetteer', 'feature',
    'Table gazetteer.feature should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'feature'::name, ARRAY[
    'feat_id'::name,
    'feat_type'::name,
    'status'::name,
    'description'::name,
    'updated_by'::name,
    'update_date'::name,
    'ref_point'::name
]);

SELECT has_column(       'gazetteer', 'feature', 'feat_id', 'Column gazetteer.feature.feat_id should exist');
SELECT col_type_is(      'gazetteer', 'feature', 'feat_id', 'integer', 'Column gazetteer.feature.feat_id should be type integer');
SELECT col_not_null(     'gazetteer', 'feature', 'feat_id', 'Column gazetteer.feature.feat_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'feature', 'feat_id', 'Column gazetteer.feature.feat_id should have a default');
SELECT col_default_is(   'gazetteer', 'feature', 'feat_id', 'nextval(''gazetteer.feature_feat_id_seq''::regclass)', 'Column gazetteer.feature.feat_id default is');

SELECT has_column(       'gazetteer', 'feature', 'feat_type', 'Column gazetteer.feature.feat_type should exist');
SELECT col_type_is(      'gazetteer', 'feature', 'feat_type', 'character(4)', 'Column gazetteer.feature.feat_type should be type character(4)');
SELECT col_not_null(     'gazetteer', 'feature', 'feat_type', 'Column gazetteer.feature.feat_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature', 'feat_type', 'Column gazetteer.feature.feat_type should not  have a default');

SELECT has_column(       'gazetteer', 'feature', 'status', 'Column gazetteer.feature.status should exist');
SELECT col_type_is(      'gazetteer', 'feature', 'status', 'character(4)', 'Column gazetteer.feature.status should be type character(4)');
SELECT col_not_null(     'gazetteer', 'feature', 'status', 'Column gazetteer.feature.status should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature', 'status', 'Column gazetteer.feature.status should not  have a default');

SELECT has_column(       'gazetteer', 'feature', 'description', 'Column gazetteer.feature.description should exist');
SELECT col_type_is(      'gazetteer', 'feature', 'description', 'text', 'Column gazetteer.feature.description should be type text');
SELECT col_is_null(      'gazetteer', 'feature', 'description', 'Column gazetteer.feature.description should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature', 'description', 'Column gazetteer.feature.description should not  have a default');

SELECT has_column(       'gazetteer', 'feature', 'updated_by', 'Column gazetteer.feature.updated_by should exist');
SELECT col_type_is(      'gazetteer', 'feature', 'updated_by', 'name', 'Column gazetteer.feature.updated_by should be type name');
SELECT col_is_null(      'gazetteer', 'feature', 'updated_by', 'Column gazetteer.feature.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature', 'updated_by', 'Column gazetteer.feature.updated_by should not  have a default');

SELECT has_column(       'gazetteer', 'feature', 'update_date', 'Column gazetteer.feature.update_date should exist');
SELECT col_type_is(      'gazetteer', 'feature', 'update_date', 'timestamp without time zone', 'Column gazetteer.feature.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'feature', 'update_date', 'Column gazetteer.feature.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature', 'update_date', 'Column gazetteer.feature.update_date should not  have a default');

SELECT has_column(       'gazetteer', 'feature', 'ref_point', 'Column gazetteer.feature.ref_point should exist');
SELECT col_type_is(      'gazetteer', 'feature', 'ref_point', 'geometry', 'Column gazetteer.feature.ref_point should be type geometry');
SELECT col_is_null(      'gazetteer', 'feature', 'ref_point', 'Column gazetteer.feature.ref_point should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature', 'ref_point', 'Column gazetteer.feature.ref_point should not  have a default');

SELECT has_trigger( 'gazetteer', 'feature', 'trg_feature_history'::name);
SELECT trigger_is(  'gazetteer', 'feature', 'trg_feature_history', 'gazetteer', 'trgfunc_feature_history');
SELECT has_trigger( 'gazetteer', 'feature', 'trg_feature_update'::name);
SELECT trigger_is(  'gazetteer', 'feature', 'trg_feature_update', 'gazetteer', 'trgfunc_feature_update');

SELECT * FROM finish();
ROLLBACK;
