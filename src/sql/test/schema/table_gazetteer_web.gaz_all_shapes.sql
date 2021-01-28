SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(15);

SELECT has_table(
    'gazetteer_web', 'gaz_all_shapes',
    'Should have table gazetteer_web.gaz_all_shapes'
);

SELECT hasnt_pk(
    'gazetteer_web', 'gaz_all_shapes',
    'Table gazetteer_web.gaz_all_shapes should have a primary key'
);

SELECT columns_are('gazetteer_web'::name, 'gaz_all_shapes'::name, ARRAY[
    'feat_id'::name,
    'geom_type'::name,
    'shape'::name
]);

SELECT has_column(       'gazetteer_web', 'gaz_all_shapes', 'feat_id', 'Column gazetteer_web.gaz_all_shapes.feat_id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_all_shapes', 'feat_id', 'integer', 'Column gazetteer_web.gaz_all_shapes.feat_id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_all_shapes', 'feat_id', 'Column gazetteer_web.gaz_all_shapes.feat_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_all_shapes', 'feat_id', 'Column gazetteer_web.gaz_all_shapes.feat_id should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_all_shapes', 'geom_type', 'Column gazetteer_web.gaz_all_shapes.geom_type should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_all_shapes', 'geom_type', 'character(1)', 'Column gazetteer_web.gaz_all_shapes.geom_type should be type character(1)');
SELECT col_not_null(     'gazetteer_web', 'gaz_all_shapes', 'geom_type', 'Column gazetteer_web.gaz_all_shapes.geom_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_all_shapes', 'geom_type', 'Column gazetteer_web.gaz_all_shapes.geom_type should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_all_shapes', 'shape', 'Column gazetteer_web.gaz_all_shapes.shape should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_all_shapes', 'shape', 'geometry', 'Column gazetteer_web.gaz_all_shapes.shape should be type geometry');
SELECT col_is_null(      'gazetteer_web', 'gaz_all_shapes', 'shape', 'Column gazetteer_web.gaz_all_shapes.shape should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_all_shapes', 'shape', 'Column gazetteer_web.gaz_all_shapes.shape should not  have a default');

SELECT * FROM finish();
ROLLBACK;
