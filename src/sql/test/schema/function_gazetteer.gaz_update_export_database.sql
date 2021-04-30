SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(1);

SELECT ok(
     gazetteer.gaz_update_export_database(),
    'Invoke gaz_update_export_database function'
);

SELECT * FROM finish();
ROLLBACK;
