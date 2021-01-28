SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(24);

SELECT has_table(
    'gazetteer_web', 'gaz_shape',
    'Should have table gazetteer_web.gaz_shape'
);

SELECT has_pk(
    'gazetteer_web', 'gaz_shape',
    'Table gazetteer_web.gaz_shape should have a primary key'
);

SELECT columns_are('gazetteer_web'::name, 'gaz_shape'::name, ARRAY[
    'id'::name,
    'feat_id'::name,
    'min_zoom'::name,
    'max_zoom'::name,
    'shape'::name
]);

SELECT has_column(       'gazetteer_web', 'gaz_shape', 'id', 'Column gazetteer_web.gaz_shape.id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_shape', 'id', 'integer', 'Column gazetteer_web.gaz_shape.id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_shape', 'id', 'Column gazetteer_web.gaz_shape.id should be NOT NULL');
SELECT col_has_default(  'gazetteer_web', 'gaz_shape', 'id', 'Column gazetteer_web.gaz_shape.id should have a default');
SELECT col_default_is(   'gazetteer_web', 'gaz_shape', 'id', 'nextval(''gazetteer_web.gaz_shape_id_seq''::regclass)', 'Column gazetteer_web.gaz_shape.id default is');

SELECT has_column(       'gazetteer_web', 'gaz_shape', 'feat_id', 'Column gazetteer_web.gaz_shape.feat_id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_shape', 'feat_id', 'integer', 'Column gazetteer_web.gaz_shape.feat_id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_shape', 'feat_id', 'Column gazetteer_web.gaz_shape.feat_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_shape', 'feat_id', 'Column gazetteer_web.gaz_shape.feat_id should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_shape', 'min_zoom', 'Column gazetteer_web.gaz_shape.min_zoom should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_shape', 'min_zoom', 'integer', 'Column gazetteer_web.gaz_shape.min_zoom should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_shape', 'min_zoom', 'Column gazetteer_web.gaz_shape.min_zoom should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_shape', 'min_zoom', 'Column gazetteer_web.gaz_shape.min_zoom should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_shape', 'max_zoom', 'Column gazetteer_web.gaz_shape.max_zoom should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_shape', 'max_zoom', 'integer', 'Column gazetteer_web.gaz_shape.max_zoom should be type integer');
SELECT col_is_null(      'gazetteer_web', 'gaz_shape', 'max_zoom', 'Column gazetteer_web.gaz_shape.max_zoom should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_shape', 'max_zoom', 'Column gazetteer_web.gaz_shape.max_zoom should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_shape', 'shape', 'Column gazetteer_web.gaz_shape.shape should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_shape', 'shape', 'geometry', 'Column gazetteer_web.gaz_shape.shape should be type geometry');
SELECT col_is_null(      'gazetteer_web', 'gaz_shape', 'shape', 'Column gazetteer_web.gaz_shape.shape should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_shape', 'shape', 'Column gazetteer_web.gaz_shape.shape should not  have a default');

SELECT * FROM finish();
ROLLBACK;
