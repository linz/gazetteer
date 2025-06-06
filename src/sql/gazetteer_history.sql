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

-- Create tables and triggers to support keeping a history of changes to tables.

SET search_path=gazetteer, public;

SET client_min_messages=WARNING;
SET client_min_messages=WARNING;

-- DROP SCHEMA IF EXISTS gazetteer_history CASCADE;

CREATE SCHEMA gazetteer_history AUTHORIZATION gazetteer_dba;

GRANT USAGE ON SCHEMA gazetteer_history TO gazetteer_admin;
GRANT USAGE ON SCHEMA gazetteer_history TO gazetteer_user;

CREATE OR REPLACE FUNCTION gaz_create_history_trigger( p_tabname name, p_icol1 name, p_icol2 name )
  RETURNS boolean AS
$BODY$
DECLARE
    v_tabhist name;
    v_cols TEXT;
    v_oldcols TEXT;
    v_comp TEXT;
    v_sql  TEXT;
    v_icols TEXT;
    v_idxname TEXT;

BEGIN
    WITH c(col) AS
    (
    SELECT quote_ident(attname) FROM pg_attribute where attrelid=p_tabname::regclass::oid and attnum>0
    )
    select
        array_to_string(array_agg(col),','),
        array_to_string(array_agg('OLD.' || col),','),
        array_to_string(array_agg(
           '(OLD.' || col || ' = NEW.' || col || ' OR (OLD.' || col || ' IS NULL AND NEW.' || col || ' IS NULL))'
           ), ' AND ')
        into v_cols, v_oldcols, v_comp
    from
        c;

    v_tabhist = 'gazetteer_history.' || p_tabname;

    -- Drop the history table..
    v_sql := 'DROP TABLE IF EXISTS ' || v_tabhist;
    EXECUTE v_sql;

    -- Drop the history table create the new version

    v_sql := $template$
CREATE TABLE %tabhist%
(
    history_id serial NOT NULL PRIMARY KEY,
    history_date TIMESTAMP,
    history_user NAME,
    history_action CHAR(1),
    LIKE %table%
);
    $template$;
    v_sql := REPLACE(v_sql, '%table%', p_tabname);
    v_sql := REPLACE(v_sql, '%tabhist%', v_tabhist);
    EXECUTE v_sql;

    -- Indexes on tables

    v_icols = p_icol1 || coalesce( ', ' || p_icol2, '' );
    v_idxname = 'idx_' || p_tabname || '_' || replace( v_icols, ', ', '_' );
    v_sql = 'CREATE INDEX ' || v_idxname || ' ON ' || v_tabhist || '( ' || v_icols || ')';
    EXECUTE v_sql;

    IF p_icol2 IS NOT NULL THEN
        v_icols = p_icol2 ||  ', ' || p_icol1;
        v_idxname = 'idx_' || p_tabname || '_' || replace( v_icols, ', ', '_' );
        v_sql = 'CREATE INDEX ' || v_idxname || ' ON ' || v_tabhist || '( ' || v_icols || ')';
        EXECUTE v_sql;
    END IF;

    -- Permission on tables

    v_sql := 'GRANT SELECT, INSERT, UPDATE, DELETE ON  ' || v_tabhist || ' TO gazetteer_admin';
    EXECUTE v_sql;

    -- Trigger function

    v_sql := $template$
CREATE OR REPLACE FUNCTION gazetteer.trgfunc_%table%_history() RETURNS trigger AS $TRIGGER$
DECLARE
    v_save BOOLEAN;
BEGIN
    v_save := TG_OP = 'DELETE';
    IF NOT v_save THEN
        v_save := NOT (%comp%);
    END IF;
    IF v_save THEN
	    INSERT INTO %tabhist% (
		history_date,
		history_user,
		history_action,
		%cols%
		)
	    SELECT
		current_timestamp,
		current_user,
		substring(TG_OP FOR 1),
		%oldcols%;
    END IF;
    RETURN NULL;
END
$TRIGGER$ LANGUAGE plpgsql SECURITY DEFINER SET search_path FROM CURRENT;
    $template$;

    v_sql := REPLACE(v_sql, '%table%', p_tabname);
    v_sql := REPLACE(v_sql, '%tabhist%', v_tabhist);
    v_sql := REPLACE(v_sql, '%cols%', v_cols);
    v_sql := REPLACE(v_sql, '%oldcols%', v_oldcols);
    v_sql := REPLACE(v_sql, '%comp%', v_comp);
    EXECUTE v_sql;

    EXECUTE 'DROP TRIGGER IF EXISTS trg_' || p_tabname || '_history ON ' || p_tabname;
    EXECUTE 'CREATE TRIGGER trg_'  || p_tabname || '_history AFTER UPDATE OR DELETE ON ' ||  p_tabname ||
        ' FOR EACH ROW EXECUTE PROCEDURE gazetteer.trgfunc_' || p_tabname || '_history()';

    RETURN TRUE;
END;
$BODY$
  LANGUAGE plpgsql;

SELECT gaz_create_history_trigger( 'feature', 'feat_id', NULL );
SELECT gaz_create_history_trigger( 'feature_annotation', 'feat_id', NULL );
SELECT gaz_create_history_trigger( 'feature_association', 'feat_id_from', 'feat_id_to' );
SELECT gaz_create_history_trigger( 'name','name_id', NULL );
SELECT gaz_create_history_trigger( 'name_event','name_id', NULL );
SELECT gaz_create_history_trigger( 'sub_event','event_id', NULL );
SELECT gaz_create_history_trigger( 'name_annotation','name_id', NULL );
SELECT gaz_create_history_trigger( 'name_association', 'name_id_from', 'name_id_to' );
SELECT gaz_create_history_trigger( 'feature_geometry', 'feat_id', NULL );
SELECT gaz_create_history_trigger( 'system_code','code_group, code', NULL );

DROP FUNCTION gaz_create_history_trigger( name, name, name )

