SET client_encoding = 'UTF-8';
BEGIN;
SELECT plan(129);

SELECT schemas_are(ARRAY[
    'gazetteer',
    'gazetteer_export',
    'gazetteer_history',
    'gazetteer_web',
    'public'
]);

SELECT schema_owner_is('gazetteer','gazetteer_dba');
--SELECT schema_owner_is('gazetteer_export','postgres');
SELECT schema_owner_is('gazetteer_history','gazetteer_dba');
SELECT schema_owner_is('gazetteer_web','postgres');
SELECT tables_are('gazetteer', ARRAY[
    'app_favourites',
    'app_usage',
    'feature',
    'feature_annotation',
    'feature_association',
    'feature_geometry',
    'name',
    'name_annotation',
    'name_association',
    'name_event',
    'system_code'
]);

SELECT table_owner_is('gazetteer','app_favourites','gazetteer_dba','gazetteer.app_favourites owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','app_usage','gazetteer_dba','gazetteer.app_usage owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','feature','gazetteer_dba','gazetteer.feature owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','feature_annotation','gazetteer_dba','gazetteer.feature_annotation owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','feature_association','gazetteer_dba','gazetteer.feature_association owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','feature_geometry','gazetteer_dba','gazetteer.feature_geometry owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','name','gazetteer_dba','gazetteer.name owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','name_annotation','gazetteer_dba','gazetteer.name_annotation owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','name_association','gazetteer_dba','gazetteer.name_association owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','name_event','gazetteer_dba','gazetteer.name_event owner is gazetteer_dba');
SELECT table_owner_is('gazetteer','system_code','gazetteer_dba','gazetteer.system_code owner is gazetteer_dba');
SELECT views_are('gazetteer', ARRAY[
    'feature_line',
    'feature_point',
    'feature_polygon',
    'feature_ref_point',
    'gazetteer_export_tables',
    'gazetteer_users',
    'name_export',
    'name_export_for_lol'
]);

SELECT view_owner_is('gazetteer','feature_line','gazetteer_dba', 'gazetteer.feature_line owner is gazetteer_dba');
SELECT view_owner_is('gazetteer','feature_point','gazetteer_dba', 'gazetteer.feature_point owner is gazetteer_dba');
SELECT view_owner_is('gazetteer','feature_polygon','gazetteer_dba', 'gazetteer.feature_polygon owner is gazetteer_dba');
SELECT view_owner_is('gazetteer','feature_ref_point','gazetteer_dba', 'gazetteer.feature_ref_point owner is gazetteer_dba');
SELECT view_owner_is('gazetteer','gazetteer_export_tables','gazetteer_dba', 'gazetteer.gazetteer_export_tables owner is gazetteer_dba');
SELECT view_owner_is('gazetteer','gazetteer_users','gazetteer_dba', 'gazetteer.gazetteer_users owner is gazetteer_dba');
SELECT view_owner_is('gazetteer','name_export','gazetteer_dba', 'gazetteer.name_export owner is gazetteer_dba');
SELECT sequences_are('gazetteer', ARRAY[
    'app_favourites_favourite_id_seq',
    'app_usage_usage_id_seq',
    'feature_annotation_annot_id_seq',
    'feature_association_assoc_id_seq',
    'feature_feat_id_seq',
    'feature_geometry_geom_id_seq',
    'name_annotation_annot_id_seq',
    'name_association_assoc_id_seq',
    'name_event_event_id_seq',
    'name_name_id_seq'
]);

SELECT sequence_owner_is('gazetteer','app_favourites_favourite_id_seq','gazetteer_dba','gazetteer.app_favourites_favourite_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer','app_usage_usage_id_seq','gazetteer_dba','gazetteer.app_usage_usage_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer','feature_annotation_annot_id_seq','gazetteer_dba','gazetteer.feature_annotation_annot_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer','feature_association_assoc_id_seq','gazetteer_dba','gazetteer.feature_association_assoc_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer','feature_feat_id_seq','gazetteer_dba','gazetteer.feature_feat_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer','feature_geometry_geom_id_seq','gazetteer_dba','gazetteer.feature_geometry_geom_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer','name_annotation_annot_id_seq','gazetteer_dba','gazetteer.name_annotation_annot_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer','name_association_assoc_id_seq','gazetteer_dba','gazetteer.name_association_assoc_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer','name_event_event_id_seq','gazetteer_dba','gazetteer.name_event_event_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer','name_name_id_seq','gazetteer_dba','gazetteer.name_name_id_seq owner is gazetteer_dba');
SELECT functions_are('gazetteer', ARRAY[
    'gapp_clear_favourite',
    'gapp_get_favourites',
    'gapp_get_recent_names',
    'gapp_is_favourite',
    'gapp_record_edited',
    'gapp_record_viewed',
    'gapp_set_favourite',
    'gaz_adduser',
    'gaz_candeletesystemcode',
    'gaz_createnewfeature',
    'gaz_degreestodms',
    'gaz_featureextents',
    'gaz_featurerelationshipistwoway',
    'gaz_isgazetteerdba',
    'gaz_isgazetteeruser',
    'gaz_namerelationshipistwoway',
    'gaz_nameterritorialauthority',
    'gaz_plaintext',
    'gaz_plaintext2',
    'gaz_plaintextwords',
    'gaz_preferredname',
    'gaz_preferrednameid',
    'gaz_removeuser',
    'gaz_searchname',
    'gaz_searchname2',
    'gaz_texthasmacrons',
    'gaz_update_export_database',
    'gweb_html_encode',
    'gweb_simplify_shapes',
    'gweb_update_gaz_all_shapes',
    'gweb_update_gaz_annotation',
    'gweb_update_gaz_code',
    'gweb_update_gaz_event',
    'gweb_update_gaz_feature',
    'gweb_update_gaz_name',
    'gweb_update_gaz_shape',
    'gweb_update_web_database',
    'trgfunc_feature_annotation_history',
    'trgfunc_feature_annotation_update',
    'trgfunc_feature_association_history',
    'trgfunc_feature_association_update',
    'trgfunc_feature_geometry_history',
    'trgfunc_feature_geometry_update',
    'trgfunc_feature_history',
    'trgfunc_feature_update',
    'trgfunc_name_annotation_history',
    'trgfunc_name_annotation_update',
    'trgfunc_name_association_history',
    'trgfunc_name_association_update',
    'trgfunc_name_event_history',
    'trgfunc_name_event_update',
    'trgfunc_name_history',
    'trgfunc_name_update',
    'trgfunc_system_code_history',
    'trgfunc_system_code_update'
]);

SELECT is(md5(p.prosrc), '6205a33109ca4789111ae21183cbb4ca', 'Function gapp_clear_favourite body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gapp_clear_favourite'
   AND proargtypes::text = '23';

SELECT is(md5(p.prosrc), 'a8371d00dade7e6892a8ba58ef10a5b1', 'Function gapp_get_favourites body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gapp_get_favourites'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), 'c65390a6a885c439a19ce6566ed9d67b', 'Function gapp_get_recent_names body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gapp_get_recent_names'
   AND proargtypes::text = '16 16 23';

SELECT is(md5(p.prosrc), 'f9ea0fe730575ebda10a6238f4e7c860', 'Function gapp_is_favourite body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gapp_is_favourite'
   AND proargtypes::text = '23';

SELECT is(md5(p.prosrc), 'e4c39a8ad2f2dd59053fdaab8b1b7bca', 'Function gapp_record_edited body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gapp_record_edited'
   AND proargtypes::text = '23';

SELECT is(md5(p.prosrc), '98484dcd342fdfd7bb0ff17d95fa027e', 'Function gapp_record_viewed body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gapp_record_viewed'
   AND proargtypes::text = '23';

SELECT is(md5(p.prosrc), 'b3f4b8b0250c49573e42d70a85fedbb3', 'Function gapp_set_favourite body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gapp_set_favourite'
   AND proargtypes::text = '23';

SELECT is(md5(p.prosrc), 'be39e5e7d1e23f88c861d02aba7cddf2', 'Function gaz_adduser body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_adduser'
   AND proargtypes::text = '19 16';

SELECT is(md5(p.prosrc), 'b6093d088f5ac0d91becd3d6a20f7e5b', 'Function gaz_candeletesystemcode body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_candeletesystemcode'
   AND proargtypes::text = '1042 1042';

SELECT is(md5(p.prosrc), 'daf13c4d1562bd1d45a6cbdaa57cc129', 'Function gaz_createnewfeature body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_createnewfeature'
   AND proargtypes::text = '1043 1043 1043';

SELECT is(md5(p.prosrc), '839984333ec13ebc6532df1db9860fa3', 'Function gaz_degreestodms body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_degreestodms'
   AND proargtypes::text = '701 23 1043';

SELECT is(md5(p.prosrc), 'c29f8f777b8534a5aabe7bcae788e69c', 'Function gaz_featureextents body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_featureextents'
   AND proargtypes::text = '23 701';

SELECT is(md5(p.prosrc), '94ca3fd4140eeba27e54ab28683fbce6', 'Function gaz_featurerelationshipistwoway body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_featurerelationshipistwoway'
   AND proargtypes::text = '1043';

SELECT is(md5(p.prosrc), 'f683cb080b29357555a20497bd6c9f5f', 'Function gaz_isgazetteerdba body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_isgazetteerdba'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '22195786a22b020bc3ac1d0cbf27fa3d', 'Function gaz_isgazetteeruser body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_isgazetteeruser'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '7d4ad5bc2c3a3241c935752b1eec1a14', 'Function gaz_namerelationshipistwoway body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_namerelationshipistwoway'
   AND proargtypes::text = '1043';

SELECT is(md5(p.prosrc), '62551b915db1b1020ec8f45757025ff5', 'Function gaz_nameterritorialauthority body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_nameterritorialauthority'
   AND proargtypes::text = '23';

SELECT is(md5(p.prosrc), '0d0194d69e0076d57da269f450946fe2', 'Function gaz_plaintext body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_plaintext'
   AND proargtypes::text = '25';

SELECT is(md5(p.prosrc), '418db08696ef84f356f529010a129690', 'Function gaz_plaintext2 body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_plaintext2'
   AND proargtypes::text = '25';

SELECT is(md5(p.prosrc), '882f0d8067f7dfcf1fd008256f21de1f', 'Function gaz_plaintextwords body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_plaintextwords'
   AND proargtypes::text = '25';

SELECT is(md5(p.prosrc), 'c3a40d8b7e10cc9923b6f56063a4b6a3', 'Function gaz_preferredname body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_preferredname'
   AND proargtypes::text = '23';

SELECT is(md5(p.prosrc), '5e474a1856cc9675531e33745bbaa5a1', 'Function gaz_preferrednameid body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_preferrednameid'
   AND proargtypes::text = '23';

SELECT is(md5(p.prosrc), 'a278c1b6dcc89b499f44390211e20b2c', 'Function gaz_removeuser body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_removeuser'
   AND proargtypes::text = '19';

SELECT is(md5(p.prosrc), 'c5b62f5eb1691151b86a7388413c8dc6', 'Function gaz_searchname body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_searchname'
   AND proargtypes::text = '1043 1043 1043 23';

SELECT is(md5(p.prosrc), '738684baedfa5bea351a2336835c3c8f', 'Function gaz_searchname2 body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_searchname2'
   AND proargtypes::text = '1043 1043 1043 1043 16 23';

SELECT is(md5(p.prosrc), '583d84b3e4d3df902d964dd15629ea60', 'Function gaz_texthasmacrons body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gaz_texthasmacrons'
   AND proargtypes::text = '25';

SELECT is(md5(p.prosrc), 'd7306a1ea1524bb5c17a56dd84f02371', 'Function gweb_html_encode body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_html_encode'
   AND proargtypes::text = '25';

SELECT is(md5(p.prosrc), '3f9e2fb64cea9c0f32f03b49d948b491', 'Function gweb_simplify_shapes body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_simplify_shapes'
   AND proargtypes::text = '23 23';

SELECT is(md5(p.prosrc), '6e6dc290ab64c0770b48db2235aad65e', 'Function gweb_update_gaz_all_shapes body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_update_gaz_all_shapes'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '529061abf01708d425c2aff77e60ffe8', 'Function gweb_update_gaz_annotation body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_update_gaz_annotation'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '360f90e06797093755b79fbeb366adc4', 'Function gweb_update_gaz_code body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_update_gaz_code'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), 'f8ef4c627e954c2202397b41b93b63d1', 'Function gweb_update_gaz_event body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_update_gaz_event'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), 'ba93c608230834e99634e32a4b6ffb2a', 'Function gweb_update_gaz_feature body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_update_gaz_feature'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), 'a4714abbe9c9f25dbd1c2a80ee2b2431', 'Function gweb_update_gaz_name body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_update_gaz_name'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), 'd51bb4101d6e2acf24f975479a42074f', 'Function gweb_update_gaz_shape body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_update_gaz_shape'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '83055992cca0dc095e7ac3a964aa08b4', 'Function gweb_update_web_database body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'gweb_update_web_database'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '90f6bbffa4d2faf1c3c8cef518094a53', 'Function trgfunc_feature_annotation_history body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_feature_annotation_history'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93d9bd6fe49b3a0f9286bd07eb9a5bc5', 'Function trgfunc_feature_annotation_update body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_feature_annotation_update'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), 'a33f7a4681e29284185eb6ea9dcbc4db', 'Function trgfunc_feature_association_history body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_feature_association_history'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93d9bd6fe49b3a0f9286bd07eb9a5bc5', 'Function trgfunc_feature_association_update body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_feature_association_update'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '77990a5574bde21152193db082f5d691', 'Function trgfunc_feature_geometry_history body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_feature_geometry_history'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93d9bd6fe49b3a0f9286bd07eb9a5bc5', 'Function trgfunc_feature_geometry_update body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_feature_geometry_update'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), 'be4b60b9bc78ec5b38c8adbbc4302018', 'Function trgfunc_feature_history body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_feature_history'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93d9bd6fe49b3a0f9286bd07eb9a5bc5', 'Function trgfunc_feature_update body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_feature_update'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), 'fca5769e76090f308947e6cd9ec81e9f', 'Function trgfunc_name_annotation_history body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_name_annotation_history'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93d9bd6fe49b3a0f9286bd07eb9a5bc5', 'Function trgfunc_name_annotation_update body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_name_annotation_update'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '040b17317b8b7979987e2cf8adc8177d', 'Function trgfunc_name_association_history body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_name_association_history'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93d9bd6fe49b3a0f9286bd07eb9a5bc5', 'Function trgfunc_name_association_update body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_name_association_update'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93a1873d929e9566f44c5666d629d348', 'Function trgfunc_name_event_history body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_name_event_history'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93d9bd6fe49b3a0f9286bd07eb9a5bc5', 'Function trgfunc_name_event_update body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_name_event_update'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '889d8c4a2432706ae726029f3d640985', 'Function trgfunc_name_history body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_name_history'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93d9bd6fe49b3a0f9286bd07eb9a5bc5', 'Function trgfunc_name_update body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_name_update'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '43ce18b5c8aac6291225a66492f6d84c', 'Function trgfunc_system_code_history body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_system_code_history'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), '93d9bd6fe49b3a0f9286bd07eb9a5bc5', 'Function trgfunc_system_code_update body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer'
   AND proname = 'trgfunc_system_code_update'
   AND proargtypes::text = '';

SELECT is(md5(p.prosrc), 'e36bd76b21fda2912e2477b5b0e4f4e6', 'Function gaz_update_export_database body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_export'
   AND proname = 'gaz_update_export_database'
   AND proargtypes::text = '';

SELECT tables_are('gazetteer_history', ARRAY[
    'feature',
    'feature_annotation',
    'feature_association',
    'feature_geometry',
    'name',
    'name_annotation',
    'name_association',
    'name_event',
    'system_code'
]);

SELECT table_owner_is('gazetteer_history','feature','gazetteer_dba','gazetteer_history.feature owner is gazetteer_dba');
SELECT table_owner_is('gazetteer_history','feature_annotation','gazetteer_dba','gazetteer_history.feature_annotation owner is gazetteer_dba');
SELECT table_owner_is('gazetteer_history','feature_association','gazetteer_dba','gazetteer_history.feature_association owner is gazetteer_dba');
SELECT table_owner_is('gazetteer_history','feature_geometry','gazetteer_dba','gazetteer_history.feature_geometry owner is gazetteer_dba');
SELECT table_owner_is('gazetteer_history','name','gazetteer_dba','gazetteer_history.name owner is gazetteer_dba');
SELECT table_owner_is('gazetteer_history','name_annotation','gazetteer_dba','gazetteer_history.name_annotation owner is gazetteer_dba');
SELECT table_owner_is('gazetteer_history','name_association','gazetteer_dba','gazetteer_history.name_association owner is gazetteer_dba');
SELECT table_owner_is('gazetteer_history','name_event','gazetteer_dba','gazetteer_history.name_event owner is gazetteer_dba');
SELECT table_owner_is('gazetteer_history','system_code','gazetteer_dba','gazetteer_history.system_code owner is gazetteer_dba');
SELECT sequences_are('gazetteer_history', ARRAY[
    'feature_annotation_history_id_seq',
    'feature_association_history_id_seq',
    'feature_geometry_history_id_seq',
    'feature_history_id_seq',
    'name_annotation_history_id_seq',
    'name_association_history_id_seq',
    'name_event_history_id_seq',
    'name_history_id_seq',
    'system_code_history_id_seq'
]);

SELECT sequence_owner_is('gazetteer_history','feature_annotation_history_id_seq','gazetteer_dba','gazetteer_history.feature_annotation_history_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer_history','feature_association_history_id_seq','gazetteer_dba','gazetteer_history.feature_association_history_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer_history','feature_geometry_history_id_seq','gazetteer_dba','gazetteer_history.feature_geometry_history_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer_history','feature_history_id_seq','gazetteer_dba','gazetteer_history.feature_history_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer_history','name_annotation_history_id_seq','gazetteer_dba','gazetteer_history.name_annotation_history_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer_history','name_association_history_id_seq','gazetteer_dba','gazetteer_history.name_association_history_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer_history','name_event_history_id_seq','gazetteer_dba','gazetteer_history.name_event_history_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer_history','name_history_id_seq','gazetteer_dba','gazetteer_history.name_history_id_seq owner is gazetteer_dba');
SELECT sequence_owner_is('gazetteer_history','system_code_history_id_seq','gazetteer_dba','gazetteer_history.system_code_history_id_seq owner is gazetteer_dba');
SELECT tables_are('gazetteer_web', ARRAY[
    'gaz_all_shapes',
    'gaz_annotation',
    'gaz_code',
    'gaz_event',
    'gaz_feature',
    'gaz_name',
    'gaz_shape',
    'gaz_web_config',
    'gaz_word'
]);

SELECT table_owner_is('gazetteer_web','gaz_all_shapes','gaz_owner','gazetteer_web.gaz_all_shapes owner is gaz_owner');
SELECT table_owner_is('gazetteer_web','gaz_annotation','gaz_owner','gazetteer_web.gaz_annotation owner is gaz_owner');
SELECT table_owner_is('gazetteer_web','gaz_code','gaz_owner','gazetteer_web.gaz_code owner is gaz_owner');
SELECT table_owner_is('gazetteer_web','gaz_event','gaz_owner','gazetteer_web.gaz_event owner is gaz_owner');
SELECT table_owner_is('gazetteer_web','gaz_feature','gaz_owner','gazetteer_web.gaz_feature owner is gaz_owner');
SELECT table_owner_is('gazetteer_web','gaz_name','gaz_owner','gazetteer_web.gaz_name owner is gaz_owner');
SELECT table_owner_is('gazetteer_web','gaz_shape','gaz_owner','gazetteer_web.gaz_shape owner is gaz_owner');
SELECT table_owner_is('gazetteer_web','gaz_web_config','gaz_owner','gazetteer_web.gaz_web_config owner is gaz_owner');
SELECT table_owner_is('gazetteer_web','gaz_word','gaz_owner','gazetteer_web.gaz_word owner is gaz_owner');
SELECT sequences_are('gazetteer_web', ARRAY[
    'gaz_annotation_id_seq',
    'gaz_shape_id_seq'
]);

SELECT sequence_owner_is('gazetteer_web','gaz_annotation_id_seq','gaz_owner','gazetteer_web.gaz_annotation_id_seq owner is gaz_owner');
SELECT sequence_owner_is('gazetteer_web','gaz_shape_id_seq','gaz_owner','gazetteer_web.gaz_shape_id_seq owner is gaz_owner');
SELECT functions_are('gazetteer_web', ARRAY[
    'gaz_dropdown_name1',
    'gaz_dropdown_name1s',
    'gaz_dropdown_name2s',
    'gaz_dropdown_name3s',
    'gaz_dropdown_names',
    'gaz_make_view',
    'gaz_matching_names',
    'gaz_matching_names_missed',
    'gaz_name_in_view',
    'gaz_plaintext',
    'gaz_plaintext2',
    'gaz_plaintextwords',
    'gaz_transform_null'
]);

SELECT is(md5(p.prosrc), '481d9adb6b7f62e54b685d1ae5565bcc', 'Function gaz_dropdown_name1 body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_dropdown_name1'
   AND proargtypes::text = '25 25';

SELECT is(md5(p.prosrc), '2e4671aaf508ebd751984e7e8e0f4263', 'Function gaz_dropdown_name1s body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_dropdown_name1s'
   AND proargtypes::text = '25 25 3214359';

SELECT is(md5(p.prosrc), '3552cbea5a57c414814f3de507f043b6', 'Function gaz_dropdown_name2s body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_dropdown_name2s'
   AND proargtypes::text = '25 25 25 3214359';

SELECT is(md5(p.prosrc), '6617ae8b6865a2580a32a17c891f457a', 'Function gaz_dropdown_name3s body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_dropdown_name3s'
   AND proargtypes::text = '25 25 25 25 3214359';

SELECT is(md5(p.prosrc), 'a7ced94391de83f664a70bb5f35dc7f9', 'Function gaz_dropdown_names body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_dropdown_names'
   AND proargtypes::text = '25 3214359';

SELECT is(md5(p.prosrc), '8f066dcb2e3806d5572f284a21084a85', 'Function gaz_make_view body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_make_view'
   AND proargtypes::text = '701 701 701 701 23 23';

SELECT is(md5(p.prosrc), 'f0c9b9ee4862ae53ecf811ec11d9c4e8', 'Function gaz_matching_names body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_matching_names'
   AND proargtypes::text = '25 3214359';

SELECT is(md5(p.prosrc), '43081676c5fccc1f5cc60fc4cff68677', 'Function gaz_matching_names_missed body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_matching_names_missed'
   AND proargtypes::text = '25 3214359';

SELECT is(md5(p.prosrc), '7349484c5ccbc468a8c3c7ee043fc9ea', 'Function gaz_name_in_view body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_name_in_view'
   AND proargtypes::text = '23 3214359';

SELECT is(md5(p.prosrc), '0d0194d69e0076d57da269f450946fe2', 'Function gaz_plaintext body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_plaintext'
   AND proargtypes::text = '25';

SELECT is(md5(p.prosrc), 'aa51b1a5bfefab1374b3843e508149f4', 'Function gaz_plaintext2 body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_plaintext2'
   AND proargtypes::text = '25';

SELECT is(md5(p.prosrc), '1fc5ba2cf2b0fd2d60c7809bd9a9be9d', 'Function gaz_plaintextwords body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_plaintextwords'
   AND proargtypes::text = '25 16';

SELECT is(md5(p.prosrc), '269b4ecb5d9f75b2b1eda9fc06fd1573', 'Function gaz_transform_null body should match checksum')
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON p.pronamespace = n.oid
 WHERE n.nspname = 'gazetteer_web'
   AND proname = 'gaz_transform_null'
   AND proargtypes::text = '3214359 23';

SELECT * FROM finish();
ROLLBACK;
