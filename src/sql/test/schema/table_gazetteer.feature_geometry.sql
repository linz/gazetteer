SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(32);

SELECT has_table(
    'gazetteer', 'feature_geometry',
    'Should have table gazetteer.feature_geometry'
);

SELECT has_pk(
    'gazetteer', 'feature_geometry',
    'Table gazetteer.feature_geometry should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'feature_geometry'::name, ARRAY[
    'geom_id'::name,
    'feat_id'::name,
    'geom_type'::name,
    'shape'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer', 'feature_geometry', 'geom_id', 'Column gazetteer.feature_geometry.geom_id should exist');
SELECT col_type_is(      'gazetteer', 'feature_geometry', 'geom_id', 'integer', 'Column gazetteer.feature_geometry.geom_id should be type integer');
SELECT col_not_null(     'gazetteer', 'feature_geometry', 'geom_id', 'Column gazetteer.feature_geometry.geom_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'feature_geometry', 'geom_id', 'Column gazetteer.feature_geometry.geom_id should have a default');
SELECT col_default_is(   'gazetteer', 'feature_geometry', 'geom_id', 'nextval(''gazetteer.feature_geometry_geom_id_seq''::regclass)', 'Column gazetteer.feature_geometry.geom_id default is');

SELECT has_column(       'gazetteer', 'feature_geometry', 'feat_id', 'Column gazetteer.feature_geometry.feat_id should exist');
SELECT col_type_is(      'gazetteer', 'feature_geometry', 'feat_id', 'integer', 'Column gazetteer.feature_geometry.feat_id should be type integer');
SELECT col_not_null(     'gazetteer', 'feature_geometry', 'feat_id', 'Column gazetteer.feature_geometry.feat_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature_geometry', 'feat_id', 'Column gazetteer.feature_geometry.feat_id should not  have a default');

SELECT has_column(       'gazetteer', 'feature_geometry', 'geom_type', 'Column gazetteer.feature_geometry.geom_type should exist');
SELECT col_type_is(      'gazetteer', 'feature_geometry', 'geom_type', 'character(1)', 'Column gazetteer.feature_geometry.geom_type should be type character(1)');
SELECT col_not_null(     'gazetteer', 'feature_geometry', 'geom_type', 'Column gazetteer.feature_geometry.geom_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature_geometry', 'geom_type', 'Column gazetteer.feature_geometry.geom_type should not  have a default');

SELECT has_column(       'gazetteer', 'feature_geometry', 'shape', 'Column gazetteer.feature_geometry.shape should exist');
SELECT col_type_is(      'gazetteer', 'feature_geometry', 'shape', 'geometry', 'Column gazetteer.feature_geometry.shape should be type geometry');
SELECT col_not_null(     'gazetteer', 'feature_geometry', 'shape', 'Column gazetteer.feature_geometry.shape should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature_geometry', 'shape', 'Column gazetteer.feature_geometry.shape should not  have a default');

SELECT has_column(       'gazetteer', 'feature_geometry', 'updated_by', 'Column gazetteer.feature_geometry.updated_by should exist');
SELECT col_type_is(      'gazetteer', 'feature_geometry', 'updated_by', 'name', 'Column gazetteer.feature_geometry.updated_by should be type name');
SELECT col_is_null(      'gazetteer', 'feature_geometry', 'updated_by', 'Column gazetteer.feature_geometry.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature_geometry', 'updated_by', 'Column gazetteer.feature_geometry.updated_by should not  have a default');

SELECT has_column(       'gazetteer', 'feature_geometry', 'update_date', 'Column gazetteer.feature_geometry.update_date should exist');
SELECT col_type_is(      'gazetteer', 'feature_geometry', 'update_date', 'timestamp without time zone', 'Column gazetteer.feature_geometry.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'feature_geometry', 'update_date', 'Column gazetteer.feature_geometry.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature_geometry', 'update_date', 'Column gazetteer.feature_geometry.update_date should not  have a default');

SELECT has_trigger( 'gazetteer', 'feature_geometry', 'trg_feature_geometry_history'::name);
SELECT trigger_is(  'gazetteer', 'feature_geometry', 'trg_feature_geometry_history', 'gazetteer', 'trgfunc_feature_geometry_history');
SELECT has_trigger( 'gazetteer', 'feature_geometry', 'trg_feature_geometry_update'::name);
SELECT trigger_is(  'gazetteer', 'feature_geometry', 'trg_feature_geometry_update', 'gazetteer', 'trgfunc_feature_geometry_update');

SELECT * FROM finish();
ROLLBACK;
