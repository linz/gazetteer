-- Set privileges and ownership of objects in gazetteer schema

set search_path=public;
set search_path=public;

set role postgres;

SET client_min_messages=WARNING;

-- Create a table tmp_sql with sql to drop foreign table constraints, 
-- disable triggers, and to restore them, and a procedure tmp_run_sql
-- to apply these changes

CREATE OR REPLACE FUNCTION tmp_acl_role( p_acl aclitem )
RETURNS varchar 
AS
$body$
    SELECT regexp_replace(
        regexp_replace($1::varchar,'=.*',''),
        '^$','PUBLIC'
        )
$body$
LANGUAGE sql;

DROP TABLE IF EXISTS tmp_sql;
CREATE TEMP TABLE tmp_sql AS
WITH tab(oid,seluser,name,acl,tabtype) AS
(
SELECT 
    cl.oid,
    CASE WHEN cl.relname ILIKE 'gazetteer_users' THEN 'PUBLIC' ELSE 'gazetteer_user' END,
    ns.nspname || '.' || cl.relname,
    cl.relacl,
    CASE WHEN cl.relkind = 'r' THEN 'TABLE' ELSE 'VIEW' END
FROM 
    pg_class cl 
    JOIN pg_namespace ns ON cl.relnamespace = ns.oid
WHERE
    ns.nspname in ('gazetteer', 'gazetteer_history')  AND
    cl.relkind in ('r','v')
),
seq(name) AS
(
    SELECT
       ns.nspname || '.' || cl.relname
    FROM 
       pg_class cl
      JOIN pg_namespace ns ON cl.relnamespace = ns.oid
    WHERE
       ns.nspname in ('gazetteer', 'gazetteer_history')  AND
       cl.relkind='S'
),
pro(name,execrole,secrole,acl) AS
(
    SELECT
       pr.oid::regprocedure::varchar,
       CASE WHEN 
           pr.proname ILIKE 'gaz_adduser' OR
           pr.proname ILIKE 'gaz_removeuser' OR
           pr.proname ILIKE 'gweb_update%' OR
           pr.proname ILIKE 'gaz_update_export_database'
       THEN
           'gazetteer_dba'
       WHEN 
           pr.proname ILIKE 'gaz_isgazetteeruser' OR
           pr.proname ILIKE 'gaz_degreestodms' OR
           pr.proname ILIKE 'gaz_featurerelationshipistwoway' OR
           pr.proname ILIKE 'gaz_namerelationshipistwoway' OR
           pr.proname ILIKE 'gaz_nameterritorialauthority' OR
           pr.proname ILIKE 'gaz_plaintext' OR
           pr.proname ILIKE 'gaz_texthasmacrons' OR
           pr.proname ILIKE 'gaz_plaintextwords' OR
           pr.proname ILIKE 'gaz_preferredname' OR
           pr.proname ILIKE 'gaz_preferrednameid' OR
           pr.proname ILIKE 'gaz_searchname' OR
           pr.proname ILIKE 'gaz_searchname2'
       THEN
           'gazetteer_user'
       WHEN 
           pr.proname ILIKE 'gaz_isgazetteeruser' OR
           pr.proname ILIKE 'gaz_isgazetteerdba'
       THEN
           'PUBLIC'
       ELSE
           'gazetteer_admin'
       END,
       CASE WHEN 
           pr.proname ILIKE 'gaz_adduser' OR
           pr.proname ILIKE 'gaz_removeuser'
       THEN
           'DEFINER'
       ELSE
           'INVOKER'
       END,
       pr.proacl
    FROM 
       pg_proc pr
       JOIN pg_namespace ns ON pr.pronamespace = ns.oid
    WHERE
       ns.nspname in ('gazetteer', 'gazetteer_history')
       -- AND pr.proname NOT IN ('gaz_adduser','gaz_removeuser')
),
wtab(oid,name,acl) AS
(
SELECT 
    cl.oid,
    ns.nspname || '.' || cl.relname,
    cl.relacl
FROM 
    pg_class cl 
    JOIN pg_namespace ns ON cl.relnamespace = ns.oid
WHERE
    ns.nspname = 'gazetteer_web' AND
    cl.relkind = 'r'
),
wseq(name) AS
(
    SELECT
       ns.nspname || '.' || cl.relname
    FROM 
       pg_class cl
      JOIN pg_namespace ns ON cl.relnamespace = ns.oid
    WHERE
       ns.nspname = 'gazetteer_web'  AND
       cl.relkind='S'
),
wpro(name,acl) AS
(
    SELECT
       pr.oid::regprocedure::varchar,
       pr.proacl
    FROM 
       pg_proc pr
       JOIN pg_namespace ns ON pr.pronamespace = ns.oid
    WHERE
       ns.nspname = 'gazetteer_web'
)

SELECT 
    'REVOKE ALL ON ' || tab.name || ' FROM ' || tmp_acl_role(unnest(acl)) AS sql,
    13 as priority
FROM
    tab 
UNION
SELECT 
    'GRANT SELECT ON ' || tab.name || ' TO ' || seluser AS sql,
    14 as priority
FROM
    tab 
UNION
SELECT 
    'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || tab.name || ' TO gazetteer_admin' AS sql,
    15 as priority
FROM
    tab 
UNION
SELECT 
    'ALTER ' || tab.tabtype || ' ' || tab.name || ' OWNER TO gazetteer_dba' AS sql,
    11 as priority
FROM
    tab 
UNION
SELECT 
    'REVOKE ALL ON FUNCTION ' || pro.name || ' FROM ' || tmp_acl_role(unnest(acl)) AS sql,
    23 as priority
FROM
    pro 
UNION
SELECT
    'GRANT EXECUTE ON FUNCTION ' || pro.name || ' TO ' || pro.execrole as sql,
    24 as priority
FROM
    pro
UNION
SELECT
    'ALTER FUNCTION ' || pro.name || ' OWNER TO ' || 
    CASE WHEN secrole = 'DEFINER' THEN 'postgres' ELSE 'gazetteer_dba' END as sql,
    21 as priority
FROM
    pro    
UNION
SELECT
    'ALTER FUNCTION ' || pro.name || ' SECURITY ' || secrole as sql,
    22 as priority
FROM
    pro    
UNION
SELECT
    'GRANT USAGE, SELECT ON SEQUENCE ' || seq.name || ' TO gazetteer_admin' as sql,
    34 as priority
FROM
    seq  

UNION
SELECT 
    'REVOKE ALL ON ' || name || ' FROM ' || tmp_acl_role(unnest(acl)) AS sql,
    113 as priority
FROM
    wtab 
UNION
SELECT 
    'GRANT SELECT ON ' || name || ' TO gaz_web_reader'  AS sql,
    114 as priority
FROM
    wtab 
UNION
SELECT 
    'GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ' || name || ' TO gaz_web_admin' AS sql,
    115 as priority
FROM
    wtab 
UNION
SELECT 
    'ALTER TABLE ' || name || ' OWNER TO gaz_owner' AS sql,
    111 as priority
FROM
    wtab 
UNION
SELECT 
    'REVOKE ALL ON FUNCTION ' || name || ' FROM ' || tmp_acl_role(unnest(acl)) AS sql,
    123 as priority
FROM
    wpro 
UNION
SELECT
    'GRANT EXECUTE ON FUNCTION ' || name || ' TO gaz_web_reader' as sql,
    124 as priority
FROM
    wpro
UNION
SELECT
    'ALTER FUNCTION ' || name || ' OWNER TO gaz_owner' as sql,
    121 as priority
FROM
    wpro    
UNION
SELECT
    'ALTER FUNCTION ' || name || ' SECURITY INVOKER' as sql,
    122 as priority
FROM
    wpro    
UNION
SELECT
    'GRANT USAGE, SELECT ON SEQUENCE ' || name || ' TO gaz_web_reader' as sql,
    134 as priority
FROM
    wseq;  

-- SELECT sql FROM tmp_sql order by priority, sql

CREATE OR REPLACE FUNCTION tmp_run_sql()
RETURNS INT
AS
$body$
DECLARE
  v_sql RECORD;
BEGIN
  FOR v_sql IN EXECUTE 'SELECT sql FROM tmp_sql order by priority, sql' LOOP
      EXECUTE v_sql.sql;
  END LOOP;
  RETURN 1;
END
$body$
LANGUAGE plpgsql;

SELECT tmp_run_sql();
  
DROP FUNCTION tmp_acl_role( aclitem );
DROP FUNCTION tmp_run_sql();
DROP TABLE tmp_sql;

-- Ensure access to geometry information

GRANT SELECT ON public.geometry_columns TO gazetteer_user;
GRANT SELECT ON public.spatial_ref_sys TO gazetteer_user;

GRANT SELECT ON public.geometry_columns TO gaz_web_reader;
GRANT SELECT ON public.spatial_ref_sys TO gaz_web_reader;

GRANT ALL privileges ON SCHEMA gazetteer_export to gazetteer_dba;

-- Web developer access to configuration tables

GRANT SELECT, INSERT, UPDATE, DELETE on gazetteer_web.gaz_web_config to gaz_web_developer;

-- Special access for LDS, CSV file processing

GRANT USAGE ON SCHEMA gazetteer_export to gazetteer_export, gaz_web_reader;
GRANT USAGE ON SCHEMA gazetteer to gazetteer_export, gaz_web_reader;
GRANT EXECUTE ON FUNCTION gazetteer.gaz_plaintext( text ) TO gazetteer_export, gaz_web_reader;

-- Set up role relationships

GRANT gazetteer_admin TO gazetteer_dba;
GRANT gazetteer_user TO gazetteer_admin;

GRANT gaz_web_admin TO gazetteer_dba;
GRANT gaz_web_reader TO gaz_web_admin;

-- Add ownership to gazetteer_dba to allow scripts to analyze tables

GRANT gaz_owner to gazetteer_dba
