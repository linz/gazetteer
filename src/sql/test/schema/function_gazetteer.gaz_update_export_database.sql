SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(1);

SELECT is(
     gazetteer.gaz_update_export_database(),
     1,
    'Invoke gaz_update_export_database function'
);

SELECT * FROM finish();
ROLLBACK;
