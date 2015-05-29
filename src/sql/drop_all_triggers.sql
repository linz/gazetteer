-- CREATE TEMP TABLE tmp_sql AS

CREATE OR REPLACE FUNCTION tmp_drop_all_triggers()
RETURNS INT
AS
$body$
DECLARE 
    v_count INTEGER;
    v_sql RECORD;
BEGIN
DROP TABLE IF EXISTS tmp_sql;
CREATE TEMP TABLE tmp_sql AS
WITH tab(oid,name) AS
(
SELECT 
    cl.oid,
    cl.relname
FROM 
    pg_class cl 
    JOIN pg_namespace ns ON cl.relnamespace = ns.oid
WHERE
    ns.nspname='gazetteer' AND
    cl.relkind='r'
)
SELECT 
    'DROP TRIGGER IF EXISTS ' || tg.tgname || ' ON gazetteer.' || tab.name  AS sql
FROM 
    pg_trigger tg
    JOIN tab ON tg.tgrelid=tab.oid
WHERE 
    tg.tgconstrrelid=0;
v_count := 0;    
FOR v_sql IN SELECT sql FROM tmp_sql LOOP
   EXECUTE v_sql.sql;
   v_count := v_count + 1;
END LOOP;
DROP TABLE IF EXISTS tmp_sql;
RETURN v_count;
END
$body$
language plpgsql;

select tmp_drop_all_triggers();
-- DROP FUNCTION tmp_drop_all_triggers();