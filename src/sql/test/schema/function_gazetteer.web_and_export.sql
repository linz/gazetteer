SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(11);

SELECT is(
     gazetteer.gaz_update_export_database(),
     1,
    'Invoke gaz_update_export_database function'
);

SELECT is(
    gazetteer.gweb_html_encode('<>'),
    '&lt;&gt;',
    'Invoke gweb_html_encode function'
);

SELECT is(
    gazetteer.gweb_update_gaz_event(),
    1,
    'Invoke gweb_update_gaz_event function'
);

SELECT is(
    gazetteer.gweb_update_gaz_code(),
    1,
    'Invoke gweb_update_gaz_code function'
);

SELECT is(
    gazetteer.gweb_update_gaz_feature(),
    1,
    'Invoke gweb_update_gaz_feature function'
);

SELECT is(
    gazetteer.gweb_update_gaz_name(),
    1,
    'Invoke gweb_update_gaz_name function'
);

SELECT is(
    gazetteer.gweb_update_gaz_annotation(),
    1,
    'Invoke gweb_update_gaz_annotation function'
);

SELECT is(
    gazetteer.gweb_simplify_shapes(100, 200),
    1,
    'Invoke gweb_simplify_shapes function'
);

SELECT is(
    gazetteer.gweb_update_gaz_shape(),
    1,
    'Invoke gweb_update_gaz_shape function'
);

SELECT is(
    gazetteer.gweb_update_gaz_all_shapes(),
    1,
    'Invoke gweb_update_gaz_all_shapes function'
);

SELECT is(
    gazetteer.gweb_update_web_database(),
    1,
    'Invoke gazetteer.gweb_update_web_database function'
);

SELECT * FROM finish();
ROLLBACK;
