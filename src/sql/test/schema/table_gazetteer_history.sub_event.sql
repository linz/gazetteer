SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(40);

SELECT has_table(
    'gazetteer_history', 'sub_event',
    'Should have table gazetteer_history.sub_event'
);

SELECT has_pk(
    'gazetteer_history', 'sub_event',
    'Table gazetteer_history.sub_event should have a primary key'
);

SELECT columns_are('gazetteer_history'::name, 'sub_event'::name, ARRAY[
    'sub_event_id'::name,
    'event_id'::name,
    'sub_event_date'::name,
    'sub_event_type'::name,
    'authority'::name,
    'sub_event_reference'::name,
    'notes'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer_history', 'sub_event', 'sub_event_id', 'Column gazetteer_history.sub_event.sub_event_id should exist');
SELECT col_type_is(      'gazetteer_history', 'sub_event', 'sub_event_id', 'serial', 'Column gazetteer_history.sub_event.sub_event_id should be type serial');
SELECT col_not_null(     'gazetteer_history', 'sub_event', 'sub_event_id', 'Column gazetteer_history.sub_event.sub_event_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'sub_event', 'sub_event_id', 'Column gazetteer_history.sub_event.sub_event_id should not have a default');
SELECT col_hasnt_default('gazetteer_history', 'sub_event', 'sub_event_id', 'Column gazetteer_history.sub_event.sub_event_id should not have a default');

SELECT has_column(       'gazetteer_history', 'sub_event', 'event_id', 'Column gazetteer_history.sub_event.event_id should exist');
SELECT col_type_is(      'gazetteer_history', 'sub_event', 'event_id', 'integer', 'Column gazetteer_history.sub_event.event_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'sub_event', 'event_id', 'Column gazetteer_history.sub_event.event_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'sub_event', 'event_id', 'Column gazetteer_history.sub_event.event_id should not have a default');

SELECT has_column(       'gazetteer_history', 'sub_event', 'sub_event_date', 'Column gazetteer_history.sub_event.sub_event_date should exist');
SELECT col_type_is(      'gazetteer_history', 'sub_event', 'sub_event_date', 'timestamp without time zone', 'Column gazetteer_history.sub_event.sub_event_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'sub_event', 'sub_event_date', 'Column gazetteer_history.sub_event.sub_event_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'sub_event', 'sub_event_date', 'Column gazetteer_history.sub_event.sub_event_date should not have a default');

SELECT has_column(       'gazetteer_history', 'sub_event', 'sub_event_type', 'Column gazetteer_history.sub_event.sub_event_type should exist');
SELECT col_type_is(      'gazetteer_history', 'sub_event', 'sub_event_type', 'character(4)', 'Column gazetteer_history.sub_event.sub_event_type should be type character(4)');
SELECT col_not_null(     'gazetteer_history', 'sub_event', 'sub_event_type', 'Column gazetteer_history.sub_event.sub_event_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'sub_event', 'sub_event_type', 'Column gazetteer_history.sub_event.sub_event_type should not have a default');

SELECT has_column(       'gazetteer_history', 'sub_event', 'authority', 'Column gazetteer_history.sub_event.authority should exist');
SELECT col_type_is(      'gazetteer_history', 'sub_event', 'authority', 'character(4)', 'Column gazetteer_history.sub_event.authority should be type character(4)');
SELECT col_not_null(      'gazetteer_history', 'sub_event', 'authority', 'Column gazetteer_history.sub_event.authority should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'sub_event', 'authority', 'Column gazetteer_history.sub_event.authority should not have a default');

SELECT has_column(       'gazetteer_history', 'sub_event', 'sub_event_reference', 'Column gazetteer_history.sub_event.sub_event_reference should exist');
SELECT col_type_is(      'gazetteer_history', 'sub_event', 'sub_event_reference', 'text', 'Column gazetteer_history.sub_event.sub_event_reference should be type text');
SELECT col_is_null(      'gazetteer_history', 'sub_event', 'sub_event_reference', 'Column gazetteer_history.sub_event.sub_event_reference should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'sub_event', 'sub_event_reference', 'Column gazetteer_history.sub_event.sub_event_reference should not  have a default');

SELECT has_column(       'gazetteer_history', 'sub_event', 'notes', 'Column gazetteer_history.sub_event.notes should exist');
SELECT col_type_is(      'gazetteer_history', 'sub_event', 'notes', 'text', 'Column gazetteer_history.sub_event.notes should be type text');
SELECT col_is_null(      'gazetteer_history', 'sub_event', 'notes', 'Column gazetteer_history.sub_event.notes should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'sub_event', 'notes', 'Column gazetteer_history.sub_event.notes should not  have a default');

SELECT has_column(       'gazetteer_history', 'sub_event', 'updated_by', 'Column gazetteer_history.sub_event.updated_by should exist');
SELECT col_type_is(      'gazetteer_history', 'sub_event', 'updated_by', 'name', 'Column gazetteer_history.sub_event.updated_by should be type name');
SELECT col_is_null(      'gazetteer_history', 'sub_event', 'updated_by', 'Column gazetteer_history.sub_event.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'sub_event', 'updated_by', 'Column gazetteer_history.sub_event.updated_by should not  have a default');

SELECT has_column(       'gazetteer_history', 'system_code', 'update_date', 'Column gazetteer_history.system_code.update_date should exist');
SELECT col_type_is(      'gazetteer_history', 'system_code', 'update_date', 'timestamp without time zone', 'Column gazetteer_history.system_code.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'system_code', 'update_date', 'Column gazetteer_history.system_code.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'system_code', 'update_date', 'Column gazetteer_history.system_code.update_date should not  have a default');

SELECT * FROM finish();
ROLLBACK;
