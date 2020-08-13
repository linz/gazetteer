SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(23);

SELECT has_table(
    'gazetteer_web', 'gaz_event',
    'Should have table gazetteer_web.gaz_event'
);

SELECT has_pk(
    'gazetteer_web', 'gaz_event',
    'Table gazetteer_web.gaz_event should have a primary key'
);

SELECT columns_are('gazetteer_web'::name, 'gaz_event'::name, ARRAY[
    'event_id'::name,
    'name_id'::name,
    'event_date'::name,
    'event_type'::name,
    'event_reference'::name
]);

SELECT has_column(       'gazetteer_web', 'gaz_event', 'event_id', 'Column gazetteer_web.gaz_event.event_id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_event', 'event_id', 'integer', 'Column gazetteer_web.gaz_event.event_id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_event', 'event_id', 'Column gazetteer_web.gaz_event.event_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_event', 'event_id', 'Column gazetteer_web.gaz_event.event_id should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_event', 'name_id', 'Column gazetteer_web.gaz_event.name_id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_event', 'name_id', 'integer', 'Column gazetteer_web.gaz_event.name_id should be type integer');
SELECT col_is_null(      'gazetteer_web', 'gaz_event', 'name_id', 'Column gazetteer_web.gaz_event.name_id should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_event', 'name_id', 'Column gazetteer_web.gaz_event.name_id should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_event', 'event_date', 'Column gazetteer_web.gaz_event.event_date should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_event', 'event_date', 'date', 'Column gazetteer_web.gaz_event.event_date should be type date');
SELECT col_is_null(      'gazetteer_web', 'gaz_event', 'event_date', 'Column gazetteer_web.gaz_event.event_date should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_event', 'event_date', 'Column gazetteer_web.gaz_event.event_date should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_event', 'event_type', 'Column gazetteer_web.gaz_event.event_type should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_event', 'event_type', 'character(4)', 'Column gazetteer_web.gaz_event.event_type should be type character(4)');
SELECT col_is_null(      'gazetteer_web', 'gaz_event', 'event_type', 'Column gazetteer_web.gaz_event.event_type should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_event', 'event_type', 'Column gazetteer_web.gaz_event.event_type should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_event', 'event_reference', 'Column gazetteer_web.gaz_event.event_reference should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_event', 'event_reference', 'text', 'Column gazetteer_web.gaz_event.event_reference should be type text');
SELECT col_is_null(      'gazetteer_web', 'gaz_event', 'event_reference', 'Column gazetteer_web.gaz_event.event_reference should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_event', 'event_reference', 'Column gazetteer_web.gaz_event.event_reference should not  have a default');

SELECT * FROM finish();
ROLLBACK;
