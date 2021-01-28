SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(44);

SELECT has_table(
    'gazetteer', 'name_event',
    'Should have table gazetteer.name_event'
);

SELECT has_pk(
    'gazetteer', 'name_event',
    'Table gazetteer.name_event should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'name_event'::name, ARRAY[
    'event_id'::name,
    'name_id'::name,
    'event_date'::name,
    'event_type'::name,
    'authority'::name,
    'event_reference'::name,
    'notes'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer', 'name_event', 'event_id', 'Column gazetteer.name_event.event_id should exist');
SELECT col_type_is(      'gazetteer', 'name_event', 'event_id', 'integer', 'Column gazetteer.name_event.event_id should be type integer');
SELECT col_not_null(     'gazetteer', 'name_event', 'event_id', 'Column gazetteer.name_event.event_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'name_event', 'event_id', 'Column gazetteer.name_event.event_id should have a default');
SELECT col_default_is(   'gazetteer', 'name_event', 'event_id', 'nextval(''gazetteer.name_event_event_id_seq''::regclass)', 'Column gazetteer.name_event.event_id default is');

SELECT has_column(       'gazetteer', 'name_event', 'name_id', 'Column gazetteer.name_event.name_id should exist');
SELECT col_type_is(      'gazetteer', 'name_event', 'name_id', 'integer', 'Column gazetteer.name_event.name_id should be type integer');
SELECT col_not_null(     'gazetteer', 'name_event', 'name_id', 'Column gazetteer.name_event.name_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'name_event', 'name_id', 'Column gazetteer.name_event.name_id should not  have a default');

SELECT has_column(       'gazetteer', 'name_event', 'event_date', 'Column gazetteer.name_event.event_date should exist');
SELECT col_type_is(      'gazetteer', 'name_event', 'event_date', 'date', 'Column gazetteer.name_event.event_date should be type date');
SELECT col_is_null(      'gazetteer', 'name_event', 'event_date', 'Column gazetteer.name_event.event_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_event', 'event_date', 'Column gazetteer.name_event.event_date should not  have a default');

SELECT has_column(       'gazetteer', 'name_event', 'event_type', 'Column gazetteer.name_event.event_type should exist');
SELECT col_type_is(      'gazetteer', 'name_event', 'event_type', 'character(4)', 'Column gazetteer.name_event.event_type should be type character(4)');
SELECT col_not_null(     'gazetteer', 'name_event', 'event_type', 'Column gazetteer.name_event.event_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'name_event', 'event_type', 'Column gazetteer.name_event.event_type should not  have a default');

SELECT has_column(       'gazetteer', 'name_event', 'authority', 'Column gazetteer.name_event.authority should exist');
SELECT col_type_is(      'gazetteer', 'name_event', 'authority', 'character(4)', 'Column gazetteer.name_event.authority should be type character(4)');
SELECT col_not_null(     'gazetteer', 'name_event', 'authority', 'Column gazetteer.name_event.authority should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'name_event', 'authority', 'Column gazetteer.name_event.authority should not  have a default');

SELECT has_column(       'gazetteer', 'name_event', 'event_reference', 'Column gazetteer.name_event.event_reference should exist');
SELECT col_type_is(      'gazetteer', 'name_event', 'event_reference', 'text', 'Column gazetteer.name_event.event_reference should be type text');
SELECT col_is_null(      'gazetteer', 'name_event', 'event_reference', 'Column gazetteer.name_event.event_reference should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_event', 'event_reference', 'Column gazetteer.name_event.event_reference should not  have a default');

SELECT has_column(       'gazetteer', 'name_event', 'notes', 'Column gazetteer.name_event.notes should exist');
SELECT col_type_is(      'gazetteer', 'name_event', 'notes', 'text', 'Column gazetteer.name_event.notes should be type text');
SELECT col_is_null(      'gazetteer', 'name_event', 'notes', 'Column gazetteer.name_event.notes should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_event', 'notes', 'Column gazetteer.name_event.notes should not  have a default');

SELECT has_column(       'gazetteer', 'name_event', 'updated_by', 'Column gazetteer.name_event.updated_by should exist');
SELECT col_type_is(      'gazetteer', 'name_event', 'updated_by', 'name', 'Column gazetteer.name_event.updated_by should be type name');
SELECT col_is_null(      'gazetteer', 'name_event', 'updated_by', 'Column gazetteer.name_event.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_event', 'updated_by', 'Column gazetteer.name_event.updated_by should not  have a default');

SELECT has_column(       'gazetteer', 'name_event', 'update_date', 'Column gazetteer.name_event.update_date should exist');
SELECT col_type_is(      'gazetteer', 'name_event', 'update_date', 'timestamp without time zone', 'Column gazetteer.name_event.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'name_event', 'update_date', 'Column gazetteer.name_event.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'name_event', 'update_date', 'Column gazetteer.name_event.update_date should not  have a default');

SELECT has_trigger( 'gazetteer', 'name_event', 'trg_name_event_history'::name);
SELECT trigger_is(  'gazetteer', 'name_event', 'trg_name_event_history', 'gazetteer', 'trgfunc_name_event_history');
SELECT has_trigger( 'gazetteer', 'name_event', 'trg_name_event_update'::name);
SELECT trigger_is(  'gazetteer', 'name_event', 'trg_name_event_update', 'gazetteer', 'trgfunc_name_event_update');

SELECT * FROM finish();
ROLLBACK;
