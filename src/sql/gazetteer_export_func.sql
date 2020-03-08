-- ################################################################################
--
--  New Zealand Geographic Board gazetteer application,
--  Crown copyright (c) 2020, Land Information New Zealand on behalf of
--  the New Zealand Government.
--
--  This file is released under the MIT licence. See the LICENCE file found
--  in the top-level directory of this distribution for more information.
--
-- ################################################################################

-- Script to update the gazetteer_export tables

set search_path=gazetteer_export, gazetteer, public;
SET client_min_messages=WARNING;

CREATE OR REPLACE FUNCTION gaz_update_export_database()
  RETURNS integer AS
$BODY$
DECLARE
    l_tabname VARCHAR;
BEGIN
    FOR l_tabname IN 
        SELECT 
            quote_ident(ns.nspname) || '.' || quote_ident(cl.relname)
        FROM 
            pg_class cl 
            JOIN pg_namespace ns ON cl.relnamespace = ns.oid
        WHERE
            ns.nspname = 'gazetteer_export' AND 
            cl.relkind = 'r' AND
            cl.relname not ilike 'metadata%'
            
    LOOP
        EXECUTE 'DROP TABLE ' || l_tabname;
    END LOOP;

    CREATE TABLE gazetteer_export.gaz_all_names AS
    SELECT
        name_id,
        name,
        status,
        feat_id,
        feat_type,
        nzgb_ref,
        land_district,
        crd_projection,
        crd_north,
        crd_east,
        crd_datum,
        crd_latitude,
        crd_longitude,
        info_ref,
        info_origin,
        info_description,
        info_note,
        feat_note,
        maori_name,
        cpa_legislation,
        conservancy,
        doc_cons_unit_no,
        doc_gaz_ref,
        treaty_legislation,
        geom_type,
        accuracy,
        gebco,
        region,
        scufn,
        height,
        ant_pn_ref,
        ant_pgaz_ref,
        scar_id,
        scar_rec_by,
        accuracy_rating,
        desc_code,
        rev_gaz_ref,
        rev_treaty_legislation,
        ref_point
    FROM
        gazetteer.name_export;

    ALTER TABLE gazetteer_export.gaz_all_names ADD PRIMARY KEY (name_id);
        ALTER TABLE gazetteer_export.gaz_all_names  OWNER TO gazetteer_dba;
        GRANT SELECT ON gazetteer_export.gaz_all_names TO gazetteer_export;
        GRANT SELECT ON gazetteer_export.gaz_all_names  TO gaz_web_reader;
        GRANT ALL ON gazetteer_export.gaz_all_names TO gazetteer_dba;

    CREATE TABLE gazetteer_export.gaz_names_csv AS
    SELECT
        name_id,
        name,
        status,
        feat_id,
        feat_type,
        nzgb_ref,
        land_district,
        crd_projection,
        crd_north,
        crd_east,
        crd_datum,
        crd_latitude,
        crd_longitude,
        info_ref,
        info_origin,
        info_description,
        info_note,
        feat_note,
        maori_name,
        cpa_legislation,
        conservancy,
        doc_cons_unit_no,
        doc_gaz_ref,
        treaty_legislation,
        geom_type,
        accuracy,
        gebco,
        region,
        scufn,
        height,
        ant_pn_ref,
        ant_pgaz_ref,
        scar_id,
        scar_rec_by,
        accuracy_rating,
        desc_code,
        rev_gaz_ref,
        rev_treaty_legislation
    FROM
        gazetteer.name_export;

    ALTER TABLE gazetteer_export.gaz_names_csv ADD PRIMARY KEY (name_id);
        ALTER TABLE gazetteer_export.gaz_names_csv  OWNER TO gazetteer_dba;
        GRANT SELECT ON gazetteer_export.gaz_names_csv TO gazetteer_export;
        GRANT SELECT ON gazetteer_export.gaz_names_csv  TO gaz_web_reader;
        GRANT ALL ON gazetteer_export.gaz_names_csv TO gazetteer_dba;

    CREATE TABLE gazetteer_export.gaz_official_names AS
    SELECT
        name_id,
        name,
        status,
        feat_id,
        feat_type,
        nzgb_ref,
        land_district,
        crd_projection,
        crd_north,
        crd_east,
        crd_datum,
        crd_latitude,
        crd_longitude,
        info_ref,
        info_origin,
        info_description,
        info_note,
        feat_note,
        maori_name,
        cpa_legislation,
        conservancy,
        doc_cons_unit_no,
        doc_gaz_ref,
        treaty_legislation,
        geom_type,
        accuracy,
        gebco,
        region,
        scufn,
        height,
        ant_pn_ref,
        ant_pgaz_ref,
        scar_id,
        scar_rec_by,
        accuracy_rating,
        desc_code,
        rev_gaz_ref,
        rev_treaty_legislation,
        ref_point
    FROM
        gazetteer.name_export
    WHERE 
        name_status_category = 'OFFC';

    ALTER TABLE gazetteer_export.gaz_official_names ADD PRIMARY KEY (name_id);
        ALTER TABLE gazetteer_export.gaz_official_names  OWNER TO gazetteer_dba;
        GRANT SELECT ON gazetteer_export.gaz_official_names TO gazetteer_export;
        GRANT SELECT ON gazetteer_export.gaz_official_names  TO gaz_web_reader;
        GRANT ALL ON gazetteer_export.gaz_official_names TO gazetteer_dba;        


    CREATE TABLE gazetteer_export.gaz_report_base_table AS
    SELECT
        name_id,
        name,
        status,
        feat_id,
        feat_type,
        nzgb_ref,
        land_district,
        crd_projection,
        crd_north,
        crd_east,
        crd_datum,
        crd_latitude,
        crd_longitude,
        info_ref,
        info_origin,
        info_description,
        info_note,
        feat_note,
        maori_name,
        cpa_legislation,
        conservancy,
        doc_cons_unit_no,
        doc_gaz_ref,
        treaty_legislation,
        for_scufn,
        geom_type,
        accuracy,
        gebco,
        region,
        scufn,
        for_scar,
        height,
        ant_pn_ref,
        ant_pgaz_ref,
        scar_id,
        scar_rec_by,
        accuracy_rating,
        desc_code,
        rev_gaz_ref,
        rev_treaty_legislation,
        last_nzgb_date,
        last_nzgb_event,
        ref_point
    FROM
        gazetteer.name_export;

    ALTER TABLE gazetteer_export.gaz_report_base_table ADD PRIMARY KEY (name_id);
        ALTER TABLE gazetteer_export.gaz_report_base_table  OWNER TO gazetteer_dba;
        GRANT SELECT ON gazetteer_export.gaz_report_base_table TO gazetteer_export;
        GRANT SELECT ON gazetteer_export.gaz_report_base_table  TO gaz_web_reader;
        GRANT ALL ON gazetteer_export.gaz_report_base_table TO gazetteer_dba;    

    --Names for LDS with line geometries
    CREATE TABLE gazetteer_export.line_export AS
    SELECT 
        NEX.name_id,
        NEX.feat_id,
        NEX.name,
        NEX.status,
        NEX.feat_type,
        NEX.nzgb_ref,
        NEX.land_district,
        NEX.crd_projection,
        NEX.crd_north,
        NEX.crd_east,
        NEX.crd_datum,
        NEX.crd_latitude,
        NEX.crd_longitude,
        trim(regexp_replace(NEX.info_ref, E'[\\n\\r]+', '', 'g' )) AS info_ref, 
        trim(regexp_replace(NEX.info_origin, E'[\\n\\r]+', '', 'g' )) AS info_origin, 
        trim(regexp_replace(NEX.info_note, E'[\\n\\r]+', '', 'g' )) AS info_note, 
        trim(regexp_replace(NEX.feat_note, E'[\\n\\r]+', '', 'g' )) AS feat_note, 
        trim(regexp_replace(NEX.info_description, E'[\\n\\r]+', '', 'g' )) AS info_description,    
        NEX.maori_name, 
        NEX.cpa_legislation,
        NEX.conservancy,
        NEX.doc_cons_unit_no,
        NEX.doc_gaz_ref,
        NEX.treaty_legislation,
        NEX.geom_type,
        NEX.accuracy,
        NEX.gebco,
        NEX.region,
        NEX.scufn,
        NEX.height,
        NEX.ant_pn_ref,
        NEX.ant_pgaz_ref,
        NEX.scar_id,
        NEX.scar_rec_by,
        NEX.accuracy_rating,
        NEX.desc_code,
        NEX.rev_gaz_ref,
        NEX.rev_treaty_legislation,
        ST_Transform(ST_Union(array_agg(LN.shape)), 4326) AS shape
    FROM gazetteer.name_export NEX
    JOIN gazetteer.feature_line LN ON NEX.feat_id = LN.feat_id 
    GROUP BY 
        NEX.name_id,
        NEX.feat_id,
        NEX.name,
        NEX.status,
        NEX.feat_type,
        NEX.nzgb_ref,
        NEX.land_district,
        NEX.crd_projection,
        NEX.crd_north,
        NEX.crd_east,
        NEX.crd_datum,
        NEX.crd_latitude,
        NEX.crd_longitude,
        NEX.info_ref, 
        NEX.info_origin, 
        NEX.info_note, 
        NEX.feat_note, 
        NEX.info_description,    
        NEX.maori_name, 
        NEX.cpa_legislation,
        NEX.conservancy,
        NEX.doc_cons_unit_no,
        NEX.doc_gaz_ref,
        NEX.treaty_legislation,
        NEX.geom_type,
        NEX.accuracy,
        NEX.gebco,
        NEX.region,
        NEX.scufn,
        NEX.height,
        NEX.ant_pn_ref,
        NEX.ant_pgaz_ref,
        NEX.scar_id,
        NEX.scar_rec_by,
        NEX.accuracy_rating,
        NEX.desc_code,
        NEX.rev_gaz_ref,
        NEX.rev_treaty_legislation;

    ALTER TABLE gazetteer_export.line_export ADD PRIMARY KEY (name_id);
        ALTER TABLE gazetteer_export.line_export  OWNER TO gazetteer_dba;
        GRANT SELECT ON gazetteer_export.line_export TO gazetteer_export;
        GRANT SELECT ON gazetteer_export.line_export  TO gaz_web_reader;
        GRANT ALL ON gazetteer_export.line_export TO gazetteer_dba;    

    --Names for LDS with polygon geometries
    CREATE TABLE gazetteer_export.polygon_export AS
    SELECT 
        NEX.name_id,
        NEX.feat_id,
        NEX.name,
        NEX.status,
        NEX.feat_type,
        NEX.nzgb_ref,
        NEX.land_district,
        NEX.crd_projection,
        NEX.crd_north,
        NEX.crd_east,
        NEX.crd_datum,
        NEX.crd_latitude,
        NEX.crd_longitude,
        trim(regexp_replace(NEX.info_ref, E'[\\n\\r]+', '', 'g' )) AS info_ref, 
        trim(regexp_replace(NEX.info_origin, E'[\\n\\r]+', '', 'g' )) AS info_origin, 
        trim(regexp_replace(NEX.info_note, E'[\\n\\r]+', '', 'g' )) AS info_note, 
        trim(regexp_replace(NEX.feat_note, E'[\\n\\r]+', '', 'g' )) AS feat_note, 
        trim(regexp_replace(NEX.info_description, E'[\\n\\r]+', '', 'g' )) AS info_description,    
        NEX.maori_name, 
        NEX.cpa_legislation,
        NEX.conservancy,
        NEX.doc_cons_unit_no,
        NEX.doc_gaz_ref,
        NEX.treaty_legislation,
        NEX.geom_type,
        NEX.accuracy,
        NEX.gebco,
        NEX.region,
        NEX.scufn,
        NEX.height,
        NEX.ant_pn_ref,
        NEX.ant_pgaz_ref,
        NEX.scar_id,
        NEX.scar_rec_by,
        NEX.accuracy_rating,
        NEX.desc_code,
        NEX.rev_gaz_ref,
        NEX.rev_treaty_legislation,
        ST_Transform(ST_Force_2D(ST_Union(array_agg(ST_Buffer(POLY.shape,0)))), 4326) AS shape
    FROM gazetteer.name_export NEX
    JOIN gazetteer.feature_polygon POLY ON NEX.feat_id = POLY.feat_id 
    GROUP BY 
        NEX.name_id,
        NEX.feat_id,
        NEX.name,
        NEX.status,
        NEX.feat_type,
        NEX.nzgb_ref,
        NEX.land_district,
        NEX.crd_projection,
        NEX.crd_north,
        NEX.crd_east,
        NEX.crd_datum,
        NEX.crd_latitude,
        NEX.crd_longitude,
        NEX.info_ref, 
        NEX.info_origin, 
        NEX.info_note, 
        NEX.feat_note, 
        NEX.info_description,    
        NEX.maori_name, 
        NEX.cpa_legislation,
        NEX.conservancy,
        NEX.doc_cons_unit_no,
        NEX.doc_gaz_ref,
        NEX.treaty_legislation,
        NEX.geom_type,
        NEX.accuracy,
        NEX.gebco,
        NEX.region,
        NEX.scufn,
        NEX.height,
        NEX.ant_pn_ref,
        NEX.ant_pgaz_ref,
        NEX.scar_id,
        NEX.scar_rec_by,
        NEX.accuracy_rating,
        NEX.desc_code,
        NEX.rev_gaz_ref,
        NEX.rev_treaty_legislation;

    ALTER TABLE gazetteer_export.polygon_export ADD PRIMARY KEY (name_id);
        ALTER TABLE gazetteer_export.polygon_export  OWNER TO gazetteer_dba;
        GRANT SELECT ON gazetteer_export.polygon_export TO gazetteer_export;
        GRANT SELECT ON gazetteer_export.polygon_export  TO gaz_web_reader;
        GRANT ALL ON gazetteer_export.polygon_export TO gazetteer_dba;

    --Names which get imported into Landonline
    CREATE TABLE gazetteer_export.name_export_for_lol AS
    SELECT
        name_id,
        name, 
        status, 
        feat_type, 
        ref_point
    FROM
        gazetteer.name_export_for_lol;

    ALTER TABLE gazetteer_export.name_export_for_lol ADD PRIMARY KEY (name_id);
        ALTER TABLE gazetteer_export.name_export_for_lol  OWNER TO gazetteer_dba;
        GRANT SELECT ON gazetteer_export.name_export_for_lol TO gazetteer_export;
        GRANT SELECT ON gazetteer_export.name_export_for_lol  TO gaz_web_reader;
        GRANT ALL ON gazetteer_export.name_export_for_lol TO gazetteer_dba;
        
    RETURN 1;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION gaz_update_export_database()
  OWNER TO gazetteer_dba;
GRANT EXECUTE ON FUNCTION gaz_update_export_database() TO gazetteer_dba;
REVOKE ALL ON FUNCTION gaz_update_export_database() FROM public;
