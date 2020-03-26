@echo off
rem
setlocal
chdir /d %~dp0

SET host=localhost
SET db=gazetteer
IF NOT "%1"=="" SET host=%1

SET psql="c:\Program Files\Postgresql\9.0\bin\psql" -h %host% -d %db%

# Set client encoding and code page to handle BOM markers

SET PGCLIENTENCODING=UTF8

echo Creating the gazetteer schema
echo "Assumes that the gazetteer database and roles have already been created

IF "%2"=="drop" %psql% -c "drop schema gazetteer cascade"
IF "%2"=="drop" %psql% -c "drop schema gazetteer_web cascade"
%psql% -f gazetteer_schema.sql
%psql% -f gazetteer_triggers.sql
%psql% -f gazetteer_history.sql
%psql% -f gazetteer_functions.sql
%psql% -f gazetteer_text_search.sql
%psql% -f gazetteer_search_functions.sql
%psql% -f gazetteer_sysdata.sql
%psql% -f gazetteer_web_schema.sql
%psql% -f gazetteer_app_schema.sql
%psql% -f gazetteer_app_funcs.sql
