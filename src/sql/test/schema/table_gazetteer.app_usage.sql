SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(24);

SELECT has_table(
    'gazetteer', 'app_usage',
    'Should have table gazetteer.app_usage'
);

SELECT has_pk(
    'gazetteer', 'app_usage',
    'Table gazetteer.app_usage should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'app_usage'::name, ARRAY[
    'usage_id'::name,
    'userid'::name,
    'name_id'::name,
    'last_view'::name,
    'last_edit'::name
]);

SELECT has_column(       'gazetteer', 'app_usage', 'usage_id', 'Column gazetteer.app_usage.usage_id should exist');
SELECT col_type_is(      'gazetteer', 'app_usage', 'usage_id', 'integer', 'Column gazetteer.app_usage.usage_id should be type integer');
SELECT col_not_null(     'gazetteer', 'app_usage', 'usage_id', 'Column gazetteer.app_usage.usage_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'app_usage', 'usage_id', 'Column gazetteer.app_usage.usage_id should have a default');
SELECT col_default_is(   'gazetteer', 'app_usage', 'usage_id', 'nextval(''gazetteer.app_usage_usage_id_seq''::regclass)', 'Column gazetteer.app_usage.usage_id default is');

SELECT has_column(       'gazetteer', 'app_usage', 'userid', 'Column gazetteer.app_usage.userid should exist');
SELECT col_type_is(      'gazetteer', 'app_usage', 'userid', 'name', 'Column gazetteer.app_usage.userid should be type name');
SELECT col_not_null(     'gazetteer', 'app_usage', 'userid', 'Column gazetteer.app_usage.userid should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'app_usage', 'userid', 'Column gazetteer.app_usage.userid should not  have a default');

SELECT has_column(       'gazetteer', 'app_usage', 'name_id', 'Column gazetteer.app_usage.name_id should exist');
SELECT col_type_is(      'gazetteer', 'app_usage', 'name_id', 'integer', 'Column gazetteer.app_usage.name_id should be type integer');
SELECT col_not_null(     'gazetteer', 'app_usage', 'name_id', 'Column gazetteer.app_usage.name_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'app_usage', 'name_id', 'Column gazetteer.app_usage.name_id should not  have a default');

SELECT has_column(       'gazetteer', 'app_usage', 'last_view', 'Column gazetteer.app_usage.last_view should exist');
SELECT col_type_is(      'gazetteer', 'app_usage', 'last_view', 'timestamp without time zone', 'Column gazetteer.app_usage.last_view should be type timestamp without time zone');
SELECT col_not_null(     'gazetteer', 'app_usage', 'last_view', 'Column gazetteer.app_usage.last_view should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'app_usage', 'last_view', 'Column gazetteer.app_usage.last_view should not  have a default');

SELECT has_column(       'gazetteer', 'app_usage', 'last_edit', 'Column gazetteer.app_usage.last_edit should exist');
SELECT col_type_is(      'gazetteer', 'app_usage', 'last_edit', 'timestamp without time zone', 'Column gazetteer.app_usage.last_edit should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'app_usage', 'last_edit', 'Column gazetteer.app_usage.last_edit should allow NULL');
SELECT col_hasnt_default('gazetteer', 'app_usage', 'last_edit', 'Column gazetteer.app_usage.last_edit should not  have a default');

SELECT * FROM finish();
ROLLBACK;
