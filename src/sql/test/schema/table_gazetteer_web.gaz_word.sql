SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(15);

SELECT has_table(
    'gazetteer_web', 'gaz_word',
    'Should have table gazetteer_web.gaz_word'
);

SELECT has_pk(
    'gazetteer_web', 'gaz_word',
    'Table gazetteer_web.gaz_word should have a primary key'
);

SELECT columns_are('gazetteer_web'::name, 'gaz_word'::name, ARRAY[
    'name_id'::name,
    'nword'::name,
    'word'::name
]);

SELECT has_column(       'gazetteer_web', 'gaz_word', 'name_id', 'Column gazetteer_web.gaz_word.name_id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_word', 'name_id', 'integer', 'Column gazetteer_web.gaz_word.name_id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_word', 'name_id', 'Column gazetteer_web.gaz_word.name_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_word', 'name_id', 'Column gazetteer_web.gaz_word.name_id should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_word', 'nword', 'Column gazetteer_web.gaz_word.nword should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_word', 'nword', 'integer', 'Column gazetteer_web.gaz_word.nword should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_word', 'nword', 'Column gazetteer_web.gaz_word.nword should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_word', 'nword', 'Column gazetteer_web.gaz_word.nword should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_word', 'word', 'Column gazetteer_web.gaz_word.word should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_word', 'word', 'character varying(100)', 'Column gazetteer_web.gaz_word.word should be type character varying(100)');
SELECT col_not_null(     'gazetteer_web', 'gaz_word', 'word', 'Column gazetteer_web.gaz_word.word should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_word', 'word', 'Column gazetteer_web.gaz_word.word should not  have a default');

SELECT * FROM finish();
ROLLBACK;
