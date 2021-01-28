SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(16);

SELECT has_table(
    'gazetteer', 'app_favourites',
    'Should have table gazetteer.app_favourites'
);

SELECT has_pk(
    'gazetteer', 'app_favourites',
    'Table gazetteer.app_favourites should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'app_favourites'::name, ARRAY[
    'favourite_id'::name,
    'userid'::name,
    'name_id'::name
]);

SELECT has_column(       'gazetteer', 'app_favourites', 'favourite_id', 'Column gazetteer.app_favourites.favourite_id should exist');
SELECT col_type_is(      'gazetteer', 'app_favourites', 'favourite_id', 'integer', 'Column gazetteer.app_favourites.favourite_id should be type integer');
SELECT col_not_null(     'gazetteer', 'app_favourites', 'favourite_id', 'Column gazetteer.app_favourites.favourite_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'app_favourites', 'favourite_id', 'Column gazetteer.app_favourites.favourite_id should have a default');
SELECT col_default_is(   'gazetteer', 'app_favourites', 'favourite_id', 'nextval(''gazetteer.app_favourites_favourite_id_seq''::regclass)', 'Column gazetteer.app_favourites.favourite_id default is');

SELECT has_column(       'gazetteer', 'app_favourites', 'userid', 'Column gazetteer.app_favourites.userid should exist');
SELECT col_type_is(      'gazetteer', 'app_favourites', 'userid', 'name', 'Column gazetteer.app_favourites.userid should be type name');
SELECT col_not_null(     'gazetteer', 'app_favourites', 'userid', 'Column gazetteer.app_favourites.userid should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'app_favourites', 'userid', 'Column gazetteer.app_favourites.userid should not  have a default');

SELECT has_column(       'gazetteer', 'app_favourites', 'name_id', 'Column gazetteer.app_favourites.name_id should exist');
SELECT col_type_is(      'gazetteer', 'app_favourites', 'name_id', 'integer', 'Column gazetteer.app_favourites.name_id should be type integer');
SELECT col_not_null(     'gazetteer', 'app_favourites', 'name_id', 'Column gazetteer.app_favourites.name_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'app_favourites', 'name_id', 'Column gazetteer.app_favourites.name_id should not  have a default');

SELECT * FROM finish();
ROLLBACK;
