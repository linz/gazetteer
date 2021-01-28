SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(19);

SELECT has_table(
    'gazetteer_web', 'gaz_web_config',
    'Should have table gazetteer_web.gaz_web_config'
);

SELECT has_pk(
    'gazetteer_web', 'gaz_web_config',
    'Table gazetteer_web.gaz_web_config should have a primary key'
);

SELECT columns_are('gazetteer_web'::name, 'gaz_web_config'::name, ARRAY[
    'code'::name,
    'intval'::name,
    'value'::name,
    'description'::name
]);

SELECT has_column(       'gazetteer_web', 'gaz_web_config', 'code', 'Column gazetteer_web.gaz_web_config.code should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_web_config', 'code', 'character(4)', 'Column gazetteer_web.gaz_web_config.code should be type character(4)');
SELECT col_not_null(     'gazetteer_web', 'gaz_web_config', 'code', 'Column gazetteer_web.gaz_web_config.code should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_web_config', 'code', 'Column gazetteer_web.gaz_web_config.code should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_web_config', 'intval', 'Column gazetteer_web.gaz_web_config.intval should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_web_config', 'intval', 'integer', 'Column gazetteer_web.gaz_web_config.intval should be type integer');
SELECT col_is_null(      'gazetteer_web', 'gaz_web_config', 'intval', 'Column gazetteer_web.gaz_web_config.intval should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_web_config', 'intval', 'Column gazetteer_web.gaz_web_config.intval should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_web_config', 'value', 'Column gazetteer_web.gaz_web_config.value should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_web_config', 'value', 'text', 'Column gazetteer_web.gaz_web_config.value should be type text');
SELECT col_is_null(      'gazetteer_web', 'gaz_web_config', 'value', 'Column gazetteer_web.gaz_web_config.value should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_web_config', 'value', 'Column gazetteer_web.gaz_web_config.value should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_web_config', 'description', 'Column gazetteer_web.gaz_web_config.description should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_web_config', 'description', 'text', 'Column gazetteer_web.gaz_web_config.description should be type text');
SELECT col_is_null(      'gazetteer_web', 'gaz_web_config', 'description', 'Column gazetteer_web.gaz_web_config.description should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_web_config', 'description', 'Column gazetteer_web.gaz_web_config.description should not  have a default');

SELECT * FROM finish();
ROLLBACK;
