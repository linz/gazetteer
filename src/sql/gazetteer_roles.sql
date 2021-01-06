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


-- Roles for the gazetteer database

CREATE ROLE gaz_owner
  NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;

CREATE ROLE gazetteer_dba
  NOSUPERUSER INHERIT NOCREATEDB CREATEROLE;

CREATE ROLE gazetteer_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

CREATE ROLE gazetteer_admin IN ROLE gazetteer_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

CREATE ROLE gaz_web_reader
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

CREATE ROLE gaz_web_admin
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

CREATE ROLE gaz_web_developer
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

CREATE ROLE gazetteer_export
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

GRANT gaz_web_admin TO gazetteer_dba;
GRANT gazetteer_admin TO gazetteer_dba;
GRANT gazetteer_user TO gazetteer_admin;

-- Login roles for web database access and web development
-- <passwords available in local repository only>

CREATE USER gaz_web IN ROLE gaz_web_reader ENCRYPTED PASSWORD '********';
CREATE USER gaz_web_dev IN ROLE gaz_web_reader, gaz_web_developer ENCRYPTED PASSWORD '********';

CREATE ROLE gaz_web_logins
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

GRANT gaz_web_logins TO gaz_web;
GRANT gaz_web_logins TO gaz_web_dev;

