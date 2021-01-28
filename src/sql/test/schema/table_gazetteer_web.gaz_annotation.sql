SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(44);

SELECT has_table(
    'gazetteer_web', 'gaz_annotation',
    'Should have table gazetteer_web.gaz_annotation'
);

SELECT has_pk(
    'gazetteer_web', 'gaz_annotation',
    'Table gazetteer_web.gaz_annotation should have a primary key'
);

SELECT columns_are('gazetteer_web'::name, 'gaz_annotation'::name, ARRAY[
    'id'::name,
    'ref_type'::name,
    'ref_id'::name,
    'sequence'::name,
    'list_view'::name,
    'details_view'::name,
    'selected_detail_view'::name,
    'is_html'::name,
    'note_type'::name,
    'note'::name
]);

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'id', 'Column gazetteer_web.gaz_annotation.id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'id', 'integer', 'Column gazetteer_web.gaz_annotation.id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_annotation', 'id', 'Column gazetteer_web.gaz_annotation.id should be NOT NULL');
SELECT col_has_default(  'gazetteer_web', 'gaz_annotation', 'id', 'Column gazetteer_web.gaz_annotation.id should have a default');
SELECT col_default_is(   'gazetteer_web', 'gaz_annotation', 'id', 'nextval(''gazetteer_web.gaz_annotation_id_seq''::regclass)', 'Column gazetteer_web.gaz_annotation.id default is');

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'ref_type', 'Column gazetteer_web.gaz_annotation.ref_type should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'ref_type', 'character(4)', 'Column gazetteer_web.gaz_annotation.ref_type should be type character(4)');
SELECT col_not_null(     'gazetteer_web', 'gaz_annotation', 'ref_type', 'Column gazetteer_web.gaz_annotation.ref_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_annotation', 'ref_type', 'Column gazetteer_web.gaz_annotation.ref_type should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'ref_id', 'Column gazetteer_web.gaz_annotation.ref_id should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'ref_id', 'integer', 'Column gazetteer_web.gaz_annotation.ref_id should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_annotation', 'ref_id', 'Column gazetteer_web.gaz_annotation.ref_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_annotation', 'ref_id', 'Column gazetteer_web.gaz_annotation.ref_id should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'sequence', 'Column gazetteer_web.gaz_annotation.sequence should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'sequence', 'integer', 'Column gazetteer_web.gaz_annotation.sequence should be type integer');
SELECT col_not_null(     'gazetteer_web', 'gaz_annotation', 'sequence', 'Column gazetteer_web.gaz_annotation.sequence should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_annotation', 'sequence', 'Column gazetteer_web.gaz_annotation.sequence should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'list_view', 'Column gazetteer_web.gaz_annotation.list_view should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'list_view', 'character(1)', 'Column gazetteer_web.gaz_annotation.list_view should be type character(1)');
SELECT col_not_null(     'gazetteer_web', 'gaz_annotation', 'list_view', 'Column gazetteer_web.gaz_annotation.list_view should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_annotation', 'list_view', 'Column gazetteer_web.gaz_annotation.list_view should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'details_view', 'Column gazetteer_web.gaz_annotation.details_view should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'details_view', 'character(1)', 'Column gazetteer_web.gaz_annotation.details_view should be type character(1)');
SELECT col_not_null(     'gazetteer_web', 'gaz_annotation', 'details_view', 'Column gazetteer_web.gaz_annotation.details_view should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_annotation', 'details_view', 'Column gazetteer_web.gaz_annotation.details_view should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'selected_detail_view', 'Column gazetteer_web.gaz_annotation.selected_detail_view should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'selected_detail_view', 'character(1)', 'Column gazetteer_web.gaz_annotation.selected_detail_view should be type character(1)');
SELECT col_not_null(     'gazetteer_web', 'gaz_annotation', 'selected_detail_view', 'Column gazetteer_web.gaz_annotation.selected_detail_view should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_annotation', 'selected_detail_view', 'Column gazetteer_web.gaz_annotation.selected_detail_view should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'is_html', 'Column gazetteer_web.gaz_annotation.is_html should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'is_html', 'character(1)', 'Column gazetteer_web.gaz_annotation.is_html should be type character(1)');
SELECT col_not_null(     'gazetteer_web', 'gaz_annotation', 'is_html', 'Column gazetteer_web.gaz_annotation.is_html should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_annotation', 'is_html', 'Column gazetteer_web.gaz_annotation.is_html should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'note_type', 'Column gazetteer_web.gaz_annotation.note_type should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'note_type', 'character(4)', 'Column gazetteer_web.gaz_annotation.note_type should be type character(4)');
SELECT col_not_null(     'gazetteer_web', 'gaz_annotation', 'note_type', 'Column gazetteer_web.gaz_annotation.note_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_annotation', 'note_type', 'Column gazetteer_web.gaz_annotation.note_type should not  have a default');

SELECT has_column(       'gazetteer_web', 'gaz_annotation', 'note', 'Column gazetteer_web.gaz_annotation.note should exist');
SELECT col_type_is(      'gazetteer_web', 'gaz_annotation', 'note', 'text', 'Column gazetteer_web.gaz_annotation.note should be type text');
SELECT col_is_null(      'gazetteer_web', 'gaz_annotation', 'note', 'Column gazetteer_web.gaz_annotation.note should allow NULL');
SELECT col_hasnt_default('gazetteer_web', 'gaz_annotation', 'note', 'Column gazetteer_web.gaz_annotation.note should not  have a default');

SELECT * FROM finish();
ROLLBACK;
