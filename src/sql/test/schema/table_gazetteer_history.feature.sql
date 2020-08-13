SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(48);

SELECT has_table(
    'gazetteer_history', 'feature',
    'Should have table gazetteer_history.feature'
);

SELECT has_pk(
    'gazetteer_history', 'feature',
    'Table gazetteer_history.feature should have a primary key'
);

SELECT columns_are('gazetteer_history'::name, 'feature'::name, ARRAY[
    'history_id'::name,
    'history_date'::name,
    'history_user'::name,
    'history_action'::name,
    'feat_id'::name,
    'feat_type'::name,
    'status'::name,
    'description'::name,
    'updated_by'::name,
    'update_date'::name,
    'ref_point'::name
]);

SELECT has_column(       'gazetteer_history', 'feature', 'history_id', 'Column gazetteer_history.feature.history_id should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'history_id', 'integer', 'Column gazetteer_history.feature.history_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'feature', 'history_id', 'Column gazetteer_history.feature.history_id should be NOT NULL');
SELECT col_has_default(  'gazetteer_history', 'feature', 'history_id', 'Column gazetteer_history.feature.history_id should have a default');
SELECT col_default_is(   'gazetteer_history', 'feature', 'history_id', 'nextval(''gazetteer_history.feature_history_id_seq''::regclass)', 'Column gazetteer_history.feature.history_id default is');

SELECT has_column(       'gazetteer_history', 'feature', 'history_date', 'Column gazetteer_history.feature.history_date should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'history_date', 'timestamp without time zone', 'Column gazetteer_history.feature.history_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'feature', 'history_date', 'Column gazetteer_history.feature.history_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'history_date', 'Column gazetteer_history.feature.history_date should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature', 'history_user', 'Column gazetteer_history.feature.history_user should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'history_user', 'name', 'Column gazetteer_history.feature.history_user should be type name');
SELECT col_is_null(      'gazetteer_history', 'feature', 'history_user', 'Column gazetteer_history.feature.history_user should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'history_user', 'Column gazetteer_history.feature.history_user should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature', 'history_action', 'Column gazetteer_history.feature.history_action should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'history_action', 'character(1)', 'Column gazetteer_history.feature.history_action should be type character(1)');
SELECT col_is_null(      'gazetteer_history', 'feature', 'history_action', 'Column gazetteer_history.feature.history_action should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'history_action', 'Column gazetteer_history.feature.history_action should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature', 'feat_id', 'Column gazetteer_history.feature.feat_id should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'feat_id', 'integer', 'Column gazetteer_history.feature.feat_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'feature', 'feat_id', 'Column gazetteer_history.feature.feat_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'feat_id', 'Column gazetteer_history.feature.feat_id should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature', 'feat_type', 'Column gazetteer_history.feature.feat_type should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'feat_type', 'character(4)', 'Column gazetteer_history.feature.feat_type should be type character(4)');
SELECT col_not_null(     'gazetteer_history', 'feature', 'feat_type', 'Column gazetteer_history.feature.feat_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'feat_type', 'Column gazetteer_history.feature.feat_type should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature', 'status', 'Column gazetteer_history.feature.status should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'status', 'character(4)', 'Column gazetteer_history.feature.status should be type character(4)');
SELECT col_not_null(     'gazetteer_history', 'feature', 'status', 'Column gazetteer_history.feature.status should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'status', 'Column gazetteer_history.feature.status should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature', 'description', 'Column gazetteer_history.feature.description should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'description', 'text', 'Column gazetteer_history.feature.description should be type text');
SELECT col_is_null(      'gazetteer_history', 'feature', 'description', 'Column gazetteer_history.feature.description should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'description', 'Column gazetteer_history.feature.description should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature', 'updated_by', 'Column gazetteer_history.feature.updated_by should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'updated_by', 'name', 'Column gazetteer_history.feature.updated_by should be type name');
SELECT col_is_null(      'gazetteer_history', 'feature', 'updated_by', 'Column gazetteer_history.feature.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'updated_by', 'Column gazetteer_history.feature.updated_by should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature', 'update_date', 'Column gazetteer_history.feature.update_date should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'update_date', 'timestamp without time zone', 'Column gazetteer_history.feature.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'feature', 'update_date', 'Column gazetteer_history.feature.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'update_date', 'Column gazetteer_history.feature.update_date should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature', 'ref_point', 'Column gazetteer_history.feature.ref_point should exist');
SELECT col_type_is(      'gazetteer_history', 'feature', 'ref_point', 'geometry', 'Column gazetteer_history.feature.ref_point should be type geometry');
SELECT col_is_null(      'gazetteer_history', 'feature', 'ref_point', 'Column gazetteer_history.feature.ref_point should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature', 'ref_point', 'Column gazetteer_history.feature.ref_point should not  have a default');

SELECT * FROM finish();
ROLLBACK;
