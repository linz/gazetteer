SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(44);

SELECT has_table(
    'gazetteer_history', 'feature_geometry',
    'Should have table gazetteer_history.feature_geometry'
);

SELECT has_pk(
    'gazetteer_history', 'feature_geometry',
    'Table gazetteer_history.feature_geometry should have a primary key'
);

SELECT columns_are('gazetteer_history'::name, 'feature_geometry'::name, ARRAY[
    'history_id'::name,
    'history_date'::name,
    'history_user'::name,
    'history_action'::name,
    'geom_id'::name,
    'feat_id'::name,
    'geom_type'::name,
    'shape'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'history_id', 'Column gazetteer_history.feature_geometry.history_id should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'history_id', 'integer', 'Column gazetteer_history.feature_geometry.history_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'feature_geometry', 'history_id', 'Column gazetteer_history.feature_geometry.history_id should be NOT NULL');
SELECT col_has_default(  'gazetteer_history', 'feature_geometry', 'history_id', 'Column gazetteer_history.feature_geometry.history_id should have a default');
SELECT col_default_is(   'gazetteer_history', 'feature_geometry', 'history_id', 'nextval(''gazetteer_history.feature_geometry_history_id_seq''::regclass)', 'Column gazetteer_history.feature_geometry.history_id default is');

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'history_date', 'Column gazetteer_history.feature_geometry.history_date should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'history_date', 'timestamp without time zone', 'Column gazetteer_history.feature_geometry.history_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'feature_geometry', 'history_date', 'Column gazetteer_history.feature_geometry.history_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_geometry', 'history_date', 'Column gazetteer_history.feature_geometry.history_date should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'history_user', 'Column gazetteer_history.feature_geometry.history_user should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'history_user', 'name', 'Column gazetteer_history.feature_geometry.history_user should be type name');
SELECT col_is_null(      'gazetteer_history', 'feature_geometry', 'history_user', 'Column gazetteer_history.feature_geometry.history_user should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_geometry', 'history_user', 'Column gazetteer_history.feature_geometry.history_user should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'history_action', 'Column gazetteer_history.feature_geometry.history_action should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'history_action', 'character(1)', 'Column gazetteer_history.feature_geometry.history_action should be type character(1)');
SELECT col_is_null(      'gazetteer_history', 'feature_geometry', 'history_action', 'Column gazetteer_history.feature_geometry.history_action should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_geometry', 'history_action', 'Column gazetteer_history.feature_geometry.history_action should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'geom_id', 'Column gazetteer_history.feature_geometry.geom_id should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'geom_id', 'integer', 'Column gazetteer_history.feature_geometry.geom_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'feature_geometry', 'geom_id', 'Column gazetteer_history.feature_geometry.geom_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_geometry', 'geom_id', 'Column gazetteer_history.feature_geometry.geom_id should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'feat_id', 'Column gazetteer_history.feature_geometry.feat_id should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'feat_id', 'integer', 'Column gazetteer_history.feature_geometry.feat_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'feature_geometry', 'feat_id', 'Column gazetteer_history.feature_geometry.feat_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_geometry', 'feat_id', 'Column gazetteer_history.feature_geometry.feat_id should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'geom_type', 'Column gazetteer_history.feature_geometry.geom_type should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'geom_type', 'character(1)', 'Column gazetteer_history.feature_geometry.geom_type should be type character(1)');
SELECT col_not_null(     'gazetteer_history', 'feature_geometry', 'geom_type', 'Column gazetteer_history.feature_geometry.geom_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_geometry', 'geom_type', 'Column gazetteer_history.feature_geometry.geom_type should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'shape', 'Column gazetteer_history.feature_geometry.shape should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'shape', 'geometry', 'Column gazetteer_history.feature_geometry.shape should be type geometry');
SELECT col_not_null(     'gazetteer_history', 'feature_geometry', 'shape', 'Column gazetteer_history.feature_geometry.shape should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_geometry', 'shape', 'Column gazetteer_history.feature_geometry.shape should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'updated_by', 'Column gazetteer_history.feature_geometry.updated_by should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'updated_by', 'name', 'Column gazetteer_history.feature_geometry.updated_by should be type name');
SELECT col_is_null(      'gazetteer_history', 'feature_geometry', 'updated_by', 'Column gazetteer_history.feature_geometry.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_geometry', 'updated_by', 'Column gazetteer_history.feature_geometry.updated_by should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_geometry', 'update_date', 'Column gazetteer_history.feature_geometry.update_date should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_geometry', 'update_date', 'timestamp without time zone', 'Column gazetteer_history.feature_geometry.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'feature_geometry', 'update_date', 'Column gazetteer_history.feature_geometry.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_geometry', 'update_date', 'Column gazetteer_history.feature_geometry.update_date should not  have a default');

SELECT * FROM finish();
ROLLBACK;
