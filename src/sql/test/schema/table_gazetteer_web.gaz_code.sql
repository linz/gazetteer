SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(19);

SELECT has_table(
    'gazetteer_web', 'gaz_code',
    'Should have table gazetteer_web.gaz_code'
);

SELECT has_pk(
    'gazetteer_web', 'gaz_code',
    'Table gazetteer_web.gaz_code should have a primary key'
);

SELECT columns_are('gazetteer_web'::name, 'gaz_code'::name, ARRAY[
    'code_group'::name,
    'code'::name,
    'category'::name,
    'value'::name
]);

SELECT has_column(       'gazetteer_web', 'gaz_code', 'code_group', 'Column gazetteer_web.gaz_code.code_group should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_code', 'code_group', 'character(4)', 'Column gazetteer_web.gaz_code.code_group should be type character(4)');
SELECT col_not_null(     'gazetteer_web', 'gaz_code', 'code_group', 'Column gazetteer_web.gaz_code.code_group should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_code', 'code_group', 'Column gazetteer_web.gaz_code.code_group should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_code', 'code', 'Column gazetteer_web.gaz_code.code should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_code', 'code', 'character(4)', 'Column gazetteer_web.gaz_code.code should be type character(4)');
SELECT col_not_null(     'gazetteer_web', 'gaz_code', 'code', 'Column gazetteer_web.gaz_code.code should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_code', 'code', 'Column gazetteer_web.gaz_code.code should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_code', 'category', 'Column gazetteer_web.gaz_code.category should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_code', 'category', 'character(4)', 'Column gazetteer_web.gaz_code.category should be type character(4)');
SELECT col_is_null(      'gazetteer_web', 'gaz_code', 'category', 'Column gazetteer_web.gaz_code.category should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_code', 'category', 'Column gazetteer_web.gaz_code.category should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_code', 'value', 'Column gazetteer_web.gaz_code.value should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_code', 'value', 'character varying(255)', 'Column gazetteer_web.gaz_code.value should be type character varying(255)');
SELECT col_is_null(      'gazetteer_web', 'gaz_code', 'value', 'Column gazetteer_web.gaz_code.value should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_code', 'value', 'Column gazetteer_web.gaz_code.value should not  have a default');

SELECT * FROM finish();
ROLLBACK;
