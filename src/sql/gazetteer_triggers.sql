SET search_path=gazetteer, public;

SET client_min_messages=WARNING;
SET client_min_messages=WARNING;

CREATE OR REPLACE FUNCTION gaz_create_update_trigger( p_tabname name )
  RETURNS boolean AS
$BODY$
DECLARE
    v_sql  TEXT;
BEGIN
    v_sql := $template$
CREATE OR REPLACE FUNCTION trgfunc_%table%_update() RETURNS trigger AS $TRIGGER$
BEGIN
    NEW.updated_by=current_user;
    NEW.update_date=current_timestamp;
    RETURN NEW;
END        
$TRIGGER$ LANGUAGE plpgsql SECURITY DEFINER SET search_path FROM CURRENT;
    $template$;

    v_sql := REPLACE(v_sql, '%table%', p_tabname);
    EXECUTE v_sql;

    EXECUTE 'DROP TRIGGER IF EXISTS trg_' || p_tabname || '_update ON ' || p_tabname;
    EXECUTE 'CREATE TRIGGER trg_'  || p_tabname || '_update BEFORE UPDATE OR INSERT ON ' ||  p_tabname ||
        ' FOR EACH ROW EXECUTE PROCEDURE trgfunc_' || p_tabname || '_update()';
    
    RETURN TRUE;
END;
$BODY$
  LANGUAGE plpgsql;

SELECT gaz_create_update_trigger( 'feature' );
SELECT gaz_create_update_trigger( 'feature_geometry' );
SELECT gaz_create_update_trigger( 'feature_annotation' );
SELECT gaz_create_update_trigger( 'feature_association' );
SELECT gaz_create_update_trigger( 'name' );
SELECT gaz_create_update_trigger( 'name_event' );
SELECT gaz_create_update_trigger( 'name_annotation' );
SELECT gaz_create_update_trigger( 'name_association' );
SELECT gaz_create_update_trigger( 'system_code' );

DROP FUNCTION gaz_create_update_trigger( name );

