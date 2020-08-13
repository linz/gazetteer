SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(32);

SELECT has_table(
    'gazetteer', 'feature_association',
    'Should have table gazetteer.feature_association'
);

SELECT has_pk(
    'gazetteer', 'feature_association',
    'Table gazetteer.feature_association should have a primary key'
);

SELECT columns_are('gazetteer'::name, 'feature_association'::name, ARRAY[
    'assoc_id'::name,
    'feat_id_from'::name,
    'feat_id_to'::name,
    'assoc_type'::name,
    'updated_by'::name,
    'update_date'::name
]);

SELECT has_column(       'gazetteer', 'feature_association', 'assoc_id', 'Column gazetteer.feature_association.assoc_id should exist');
SELECT col_type_is(      'gazetteer', 'feature_association', 'assoc_id', 'integer', 'Column gazetteer.feature_association.assoc_id should be type integer');
SELECT col_not_null(     'gazetteer', 'feature_association', 'assoc_id', 'Column gazetteer.feature_association.assoc_id should be NOT NULL');
SELECT col_has_default(  'gazetteer', 'feature_association', 'assoc_id', 'Column gazetteer.feature_association.assoc_id should have a default');
SELECT col_default_is(   'gazetteer', 'feature_association', 'assoc_id', 'nextval(''gazetteer.feature_association_assoc_id_seq''::regclass)', 'Column gazetteer.feature_association.assoc_id default is');

SELECT has_column(       'gazetteer', 'feature_association', 'feat_id_from', 'Column gazetteer.feature_association.feat_id_from should exist');
SELECT col_type_is(      'gazetteer', 'feature_association', 'feat_id_from', 'integer', 'Column gazetteer.feature_association.feat_id_from should be type integer');
SELECT col_not_null(     'gazetteer', 'feature_association', 'feat_id_from', 'Column gazetteer.feature_association.feat_id_from should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature_association', 'feat_id_from', 'Column gazetteer.feature_association.feat_id_from should not  have a default');

SELECT has_column(       'gazetteer', 'feature_association', 'feat_id_to', 'Column gazetteer.feature_association.feat_id_to should exist');
SELECT col_type_is(      'gazetteer', 'feature_association', 'feat_id_to', 'integer', 'Column gazetteer.feature_association.feat_id_to should be type integer');
SELECT col_not_null(     'gazetteer', 'feature_association', 'feat_id_to', 'Column gazetteer.feature_association.feat_id_to should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature_association', 'feat_id_to', 'Column gazetteer.feature_association.feat_id_to should not  have a default');

SELECT has_column(       'gazetteer', 'feature_association', 'assoc_type', 'Column gazetteer.feature_association.assoc_type should exist');
SELECT col_type_is(      'gazetteer', 'feature_association', 'assoc_type', 'character(4)', 'Column gazetteer.feature_association.assoc_type should be type character(4)');
SELECT col_not_null(     'gazetteer', 'feature_association', 'assoc_type', 'Column gazetteer.feature_association.assoc_type should be NOT NULL');
SELECT col_hasnt_default('gazetteer', 'feature_association', 'assoc_type', 'Column gazetteer.feature_association.assoc_type should not  have a default');

SELECT has_column(       'gazetteer', 'feature_association', 'updated_by', 'Column gazetteer.feature_association.updated_by should exist');
SELECT col_type_is(      'gazetteer', 'feature_association', 'updated_by', 'name', 'Column gazetteer.feature_association.updated_by should be type name');
SELECT col_is_null(      'gazetteer', 'feature_association', 'updated_by', 'Column gazetteer.feature_association.updated_by should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature_association', 'updated_by', 'Column gazetteer.feature_association.updated_by should not  have a default');

SELECT has_column(       'gazetteer', 'feature_association', 'update_date', 'Column gazetteer.feature_association.update_date should exist');
SELECT col_type_is(      'gazetteer', 'feature_association', 'update_date', 'timestamp without time zone', 'Column gazetteer.feature_association.update_date should be type timestamp without time zone');
SELECT col_is_null(      'gazetteer', 'feature_association', 'update_date', 'Column gazetteer.feature_association.update_date should allow NULL');
SELECT col_hasnt_default('gazetteer', 'feature_association', 'update_date', 'Column gazetteer.feature_association.update_date should not  have a default');

SELECT has_trigger( 'gazetteer', 'feature_association', 'trg_feature_association_history'::name);
SELECT trigger_is(  'gazetteer', 'feature_association', 'trg_feature_association_history', 'gazetteer', 'trgfunc_feature_association_history');
SELECT has_trigger( 'gazetteer', 'feature_association', 'trg_feature_association_update'::name);
SELECT trigger_is(  'gazetteer', 'feature_association', 'trg_feature_association_update', 'gazetteer', 'trgfunc_feature_association_update');

SELECT * FROM finish();
ROLLBACK;
