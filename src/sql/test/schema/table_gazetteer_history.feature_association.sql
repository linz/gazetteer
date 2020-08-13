SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(44);

SELECT has_table(
    'gazetteer_history', 'feature_association',
    'Should have table gazetteer_history.feature_association'
);

SELECT has_pk(
    'gazetteer_history', 'feature_association',
    'Table gazetteer_history.feature_association should have a primary key'
);

SELECT columns_are('gazetteer_history'::name, 'feature_association'::name, ARRAY[
    'history_id'::name,
    'history_date'::name,
    'history_user'::name,
    'history_action'::name,
    'assoc_id'::name,
    'feat_id_from'::name,
    'feat_id_to'::name,
    'assoc_type'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer_history', 'feature_association', 'history_id', 'Column gazetteer_history.feature_association.history_id should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'history_id', 'integer', 'Column gazetteer_history.feature_association.history_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'feature_association', 'history_id', 'Column gazetteer_history.feature_association.history_id should be NOT NULL');
SELECT col_has_default(  'gazetteer_history', 'feature_association', 'history_id', 'Column gazetteer_history.feature_association.history_id should have a default');
SELECT col_default_is(   'gazetteer_history', 'feature_association', 'history_id', 'nextval(''gazetteer_history.feature_association_history_id_seq''::regclass)', 'Column gazetteer_history.feature_association.history_id default is');

SELECT has_column(       'gazetteer_history', 'feature_association', 'history_date', 'Column gazetteer_history.feature_association.history_date should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'history_date', 'timestamp without time zone', 'Column gazetteer_history.feature_association.history_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'feature_association', 'history_date', 'Column gazetteer_history.feature_association.history_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_association', 'history_date', 'Column gazetteer_history.feature_association.history_date should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_association', 'history_user', 'Column gazetteer_history.feature_association.history_user should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'history_user', 'name', 'Column gazetteer_history.feature_association.history_user should be type name');
SELECT col_is_null(      'gazetteer_history', 'feature_association', 'history_user', 'Column gazetteer_history.feature_association.history_user should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_association', 'history_user', 'Column gazetteer_history.feature_association.history_user should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_association', 'history_action', 'Column gazetteer_history.feature_association.history_action should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'history_action', 'character(1)', 'Column gazetteer_history.feature_association.history_action should be type character(1)');
SELECT col_is_null(      'gazetteer_history', 'feature_association', 'history_action', 'Column gazetteer_history.feature_association.history_action should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_association', 'history_action', 'Column gazetteer_history.feature_association.history_action should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_association', 'assoc_id', 'Column gazetteer_history.feature_association.assoc_id should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'assoc_id', 'integer', 'Column gazetteer_history.feature_association.assoc_id should be type integer');
SELECT col_not_null(     'gazetteer_history', 'feature_association', 'assoc_id', 'Column gazetteer_history.feature_association.assoc_id should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_association', 'assoc_id', 'Column gazetteer_history.feature_association.assoc_id should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_association', 'feat_id_from', 'Column gazetteer_history.feature_association.feat_id_from should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'feat_id_from', 'integer', 'Column gazetteer_history.feature_association.feat_id_from should be type integer');
SELECT col_not_null(     'gazetteer_history', 'feature_association', 'feat_id_from', 'Column gazetteer_history.feature_association.feat_id_from should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_association', 'feat_id_from', 'Column gazetteer_history.feature_association.feat_id_from should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_association', 'feat_id_to', 'Column gazetteer_history.feature_association.feat_id_to should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'feat_id_to', 'integer', 'Column gazetteer_history.feature_association.feat_id_to should be type integer');
SELECT col_not_null(     'gazetteer_history', 'feature_association', 'feat_id_to', 'Column gazetteer_history.feature_association.feat_id_to should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_association', 'feat_id_to', 'Column gazetteer_history.feature_association.feat_id_to should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_association', 'assoc_type', 'Column gazetteer_history.feature_association.assoc_type should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'assoc_type', 'character(4)', 'Column gazetteer_history.feature_association.assoc_type should be type character(4)');
SELECT col_not_null(     'gazetteer_history', 'feature_association', 'assoc_type', 'Column gazetteer_history.feature_association.assoc_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_association', 'assoc_type', 'Column gazetteer_history.feature_association.assoc_type should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_association', 'updated_by', 'Column gazetteer_history.feature_association.updated_by should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'updated_by', 'name', 'Column gazetteer_history.feature_association.updated_by should be type name');
SELECT col_is_null(      'gazetteer_history', 'feature_association', 'updated_by', 'Column gazetteer_history.feature_association.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_association', 'updated_by', 'Column gazetteer_history.feature_association.updated_by should not  have a default');

SELECT has_column(       'gazetteer_history', 'feature_association', 'update_date', 'Column gazetteer_history.feature_association.update_date should exist');
SELECT col_type_is(      'gazetteer_history', 'feature_association', 'update_date', 'timestamp without time zone', 'Column gazetteer_history.feature_association.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer_history', 'feature_association', 'update_date', 'Column gazetteer_history.feature_association.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer_history', 'feature_association', 'update_date', 'Column gazetteer_history.feature_association.update_date should not  have a default');

SELECT * FROM finish();
ROLLBACK;
