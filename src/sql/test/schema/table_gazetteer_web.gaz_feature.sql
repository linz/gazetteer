SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(19);

SELECT has_table(
    'gazetteer_web', 'gaz_feature',
    'Should have table gazetteer_web.gaz_feature'
);

SELECT has_pk(
    'gazetteer_web', 'gaz_feature',
    'Table gazetteer_web.gaz_feature should have a primary key'
);

SELECT columns_are('gazetteer_web'::name, 'gaz_feature'::name, ARRAY[
    'id'::name,
    'type'::name,
    'status'::name,
    'description'::name
]);

SELECT has_column(       'gazetteer_web', 'gaz_feature', 'id', 'Column gazetteer_web.gaz_feature.id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_feature', 'id', 'integer', 'Column gazetteer_web.gaz_feature.id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_feature', 'id', 'Column gazetteer_web.gaz_feature.id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_feature', 'id', 'Column gazetteer_web.gaz_feature.id should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_feature', 'type', 'Column gazetteer_web.gaz_feature.type should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_feature', 'type', 'character(4)', 'Column gazetteer_web.gaz_feature.type should be type character(4)');
SELECT col_not_null(     'gazetteer_web', 'gaz_feature', 'type', 'Column gazetteer_web.gaz_feature.type should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_feature', 'type', 'Column gazetteer_web.gaz_feature.type should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_feature', 'status', 'Column gazetteer_web.gaz_feature.status should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_feature', 'status', 'character(4)', 'Column gazetteer_web.gaz_feature.status should be type character(4)');
SELECT col_not_null(     'gazetteer_web', 'gaz_feature', 'status', 'Column gazetteer_web.gaz_feature.status should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_feature', 'status', 'Column gazetteer_web.gaz_feature.status should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_feature', 'description', 'Column gazetteer_web.gaz_feature.description should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_feature', 'description', 'text', 'Column gazetteer_web.gaz_feature.description should be type text');
SELECT col_is_null(      'gazetteer_web', 'gaz_feature', 'description', 'Column gazetteer_web.gaz_feature.description should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_feature', 'description', 'Column gazetteer_web.gaz_feature.description should not  have a default');

SELECT * FROM finish();
ROLLBACK;
