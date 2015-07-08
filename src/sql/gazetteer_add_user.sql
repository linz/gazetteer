-- ###############################################################################
-- 
--  Copyright 2015 Crown copyright (c)
--  Land Information New Zealand and the New Zealand Government.
--  All rights reserved
-- 
--  This program is released under the terms of the new BSD license. See the 
--  LICENSE file for more information.
-- 
-- ###############################################################################


SET search_path=gazetteer, public;
SET role postgres;

DROP FUNCTION IF EXISTS gaz_AddUser( name, bool ) CASCADE;

CREATE OR REPLACE FUNCTION gaz_AddUser(  p_userid name, p_isdba bool )
RETURNS INT
AS
$body$
DECLARE 
    l_exists BOOL;
BEGIN
    IF NOT EXISTS (SELECT * FROM pg_user WHERE usename=p_userid ) THEN
	EXECUTE 'CREATE ROLE "' || p_userid || 
	   '" LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE';
    END IF;
    EXECUTE 'GRANT gazetteer_admin TO "' || p_userid || '"';
    IF p_isdba THEN
        EXECUTE 'GRANT gazetteer_dba TO "' || p_userid || '"';
    ELSE
	EXECUTE 'REVOKE gazetteer_dba FROM "' || p_userid || '"';       
    END IF;
    RETURN 1;
END
$body$
LANGUAGE plpgsql
SECURITY DEFINER;

REVOKE EXECUTE ON FUNCTION gazetteer.gaz_AddUser( name, bool ) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION gazetteer.gaz_AddUser( name, bool ) TO gazetteer_dba;

DROP FUNCTION IF EXISTS gaz_RemoveUser( name ) CASCADE;

CREATE FUNCTION gaz_RemoveUser( p_userid name )
RETURNS INT
AS
$body$
BEGIN
   IF EXISTS (SELECT * FROM pg_user WHERE usename=p_userid ) THEN
	EXECUTE 'REVOKE gazetteer_admin FROM "' || p_userid || '"';
	EXECUTE 'REVOKE gazetteer_dba FROM "' || p_userid || '"';
    END IF;
    RETURN 1;
END
   
$body$
LANGUAGE plpgsql
SECURITY DEFINER;

REVOKE EXECUTE ON FUNCTION gazetteer.gaz_RemoveUser( name ) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION gazetteer.gaz_RemoveUser( name ) TO gazetteer_dba;

-- Create view of explicit database users (ie members of roles)

DROP VIEW IF EXISTS gazetteer_users;

CREATE OR REPLACE VIEW gazetteer_users 
AS
SELECT 
   r.rolname as userid,
   CASE WHEN rmdba.member IS NULL THEN FALSE ELSE TRUE END AS isdba
FROM
   pg_roles r
   JOIN pg_auth_members rm ON rm.member = r.oid
   JOIN pg_roles ruser ON ruser.oid = rm.roleid AND ruser.rolname='gazetteer_admin'
   LEFT OUTER JOIN pg_auth_members rmdba ON rmdba.member = r.oid AND
      rmdba.roleid = (SELECT oid FROM pg_roles WHERE rolname='gazetteer_dba')   
WHERE
   r.rolcanlogin;

CREATE RULE gaz_users_ins AS ON INSERT TO gazetteer_users DO INSTEAD
  SELECT gaz_AddUser( NEW.userid, NEW.isdba );

CREATE RULE gaz_users_upd AS ON UPDATE TO gazetteer_users DO INSTEAD
  SELECT gaz_AddUser( OLD.userid, NEW.isdba );
  
CREATE RULE gaz_users_del AS ON DELETE TO gazetteer_users DO INSTEAD
  SELECT gaz_RemoveUser( OLD.userid );

-- Create functions to test current user status

CREATE OR REPLACE FUNCTION gaz_IsGazetteerUser()
RETURNS BOOL
AS
$code$
   SELECT EXISTS (SELECT * FROM gazetteer_users WHERE userid=current_user);
$code$
LANGUAGE sql
SET search_path FROM CURRENT;

-- Create functions to test current user status

CREATE OR REPLACE FUNCTION gaz_IsGazetteerDba()
RETURNS BOOL
AS
$code$
   SELECT EXISTS (SELECT * FROM gazetteer_users WHERE userid=current_user AND isdba);
$code$
LANGUAGE sql
SET search_path FROM CURRENT;
  
-- INSERT INTO gazetteer_users (userid, isdba) values ( 'peter', TRUE )
-- UPDATE gazetteer_users SET isdba=FALSE WHERE userid='peter';
-- DELETE FROM gazetteer_users WHERE userid='peter';
-- SELECT * FROM gazetteer_users;
-- SELECT gaz_IsGazetteerUser()
-- SELECT gaz_IsGazetteerDba()

