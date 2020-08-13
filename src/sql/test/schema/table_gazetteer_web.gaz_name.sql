SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(27);

SELECT has_table(
    'gazetteer_web', 'gaz_name',
    'Should have table gazetteer_web.gaz_name'
);

SELECT has_pk(
    'gazetteer_web', 'gaz_name',
    'Table gazetteer_web.gaz_name should have a primary key'
);

SELECT columns_are('gazetteer_web'::name, 'gaz_name'::name, ARRAY[
    'id'::name,
    'feat_id'::name,
    'name'::name,
    'ascii_name'::name,
    'status'::name,
    'extents'::name
]);

SELECT has_column(       'gazetteer_web', 'gaz_name', 'id', 'Column gazetteer_web.gaz_name.id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_name', 'id', 'integer', 'Column gazetteer_web.gaz_name.id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_name', 'id', 'Column gazetteer_web.gaz_name.id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_name', 'id', 'Column gazetteer_web.gaz_name.id should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_name', 'feat_id', 'Column gazetteer_web.gaz_name.feat_id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_name', 'feat_id', 'integer', 'Column gazetteer_web.gaz_name.feat_id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_name', 'feat_id', 'Column gazetteer_web.gaz_name.feat_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_name', 'feat_id', 'Column gazetteer_web.gaz_name.feat_id should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_name', 'name', 'Column gazetteer_web.gaz_name.name should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_name', 'name', 'character varying(100)', 'Column gazetteer_web.gaz_name.name should be type character varying(100)');
SELECT col_not_null(     'gazetteer_web', 'gaz_name', 'name', 'Column gazetteer_web.gaz_name.name should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_name', 'name', 'Column gazetteer_web.gaz_name.name should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_name', 'ascii_name', 'Column gazetteer_web.gaz_name.ascii_name should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_name', 'ascii_name', 'character varying(100)', 'Column gazetteer_web.gaz_name.ascii_name should be type character varying(100)');
SELECT col_not_null(     'gazetteer_web', 'gaz_name', 'ascii_name', 'Column gazetteer_web.gaz_name.ascii_name should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_name', 'ascii_name', 'Column gazetteer_web.gaz_name.ascii_name should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_name', 'status', 'Column gazetteer_web.gaz_name.status should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_name', 'status', 'character(4)', 'Column gazetteer_web.gaz_name.status should be type character(4)');
SELECT col_not_null(     'gazetteer_web', 'gaz_name', 'status', 'Column gazetteer_web.gaz_name.status should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_name', 'status', 'Column gazetteer_web.gaz_name.status should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_name', 'extents', 'Column gazetteer_web.gaz_name.extents should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_name', 'extents', 'geometry', 'Column gazetteer_web.gaz_name.extents should be type geometry');
SELECT col_is_null(      'gazetteer_web', 'gaz_name', 'extents', 'Column gazetteer_web.gaz_name.extents should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_name', 'extents', 'Column gazetteer_web.gaz_name.extents should not  have a default');

SELECT * FROM finish();
ROLLBACK;
