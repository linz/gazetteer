
-- Script to update the gazetteer_export tables

set search_path=gazetteer_export, gazetteer, public;
set search_path=gazetteer_export, gazetteer, public;
SET client_min_messages=WARNING;

CREATE OR REPLACE FUNCTION gazetteer.gaz_update_export_database()
RETURNS INT
AS
$body$
DECLARE
    l_tabname VARCHAR;
    l_tabtype VARCHAR(4);
    l_tabcols VARCHAR[];
    l_tabcrit VARCHAR[];
    l_export_code VARCHAR(4);
    l_update VARCHAR(256);
    l_sql VARCHAR;
    l_cols VARCHAR;
    l_col VARCHAR;
    l_keycol VARCHAR;
BEGIN
    FOR l_tabname IN 
        SELECT 
            quote_ident(ns.nspname) || '.' || quote_ident(cl.relname)
        FROM 
            pg_class cl 
            JOIN pg_namespace ns ON cl.relnamespace = ns.oid
        WHERE
            ns.nspname = 'gazetteer_export' AND 
            cl.relkind = 'r'
    LOOP
        EXECUTE 'DROP TABLE ' || l_tabname;
    END LOOP;

    FOR l_tabname, l_tabtype, l_tabcols, l_tabcrit IN 
       SELECT data_set_name, data_set_type, data_columns, criteria FROM gazetteer_export_tables
    LOOP
        l_cols = '';
        l_keycol = '';
        FOR l_col IN
           SELECT c FROM unnest(l_tabcols) c ORDER BY c
        LOOP
            l_cols = l_cols || ',' || substring(l_col FROM 6);
            IF l_keycol = '' THEN l_keycol = substring(l_col FROM 6); END IF;
        END LOOP;
        l_cols = substring(l_cols FROM 2);
        EXECUTE 'CREATE TABLE gazetteer_export.' || l_tabname || ' AS' ||
             ' SELECT ' || l_cols || 
             ' FROM gazetteer.name_export' ||
             (CASE WHEN array_length(l_tabcrit, 1) > 0 THEN
                ' WHERE ' || array_to_string(l_tabcrit,' AND ') ELSE
                '' END);
        EXECUTE 'ALTER TABLE gazetteer_export.' || l_tabname || ' ADD PRIMARY KEY (' || l_keycol || ')';
        EXECUTE 'ALTER TABLE gazetteer_export.' || l_tabname || ' OWNER TO gazetteer_dba';
        EXECUTE 'GRANT SELECT ON gazetteer_export.' || l_tabname || ' TO gazetteer_export';
        EXECUTE 'GRANT SELECT ON gazetteer_export.' || l_tabname || ' TO gaz_web_reader';
        EXECUTE 'GRANT ALL ON gazetteer_export.' || l_tabname || ' TO gazetteer_dba';
    END LOOP;
    RETURN 1;
END
$body$
LANGUAGE plpgsql
SET search_path FROM CURRENT;

-- SELECT gazetteer.gaz_update_export_database()

GRANT EXECUTE ON FUNCTION gazetteer.gaz_update_export_database() TO gazetteer_dba;
