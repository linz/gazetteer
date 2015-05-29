@echo off
rem 
setlocal
chdir /d %~dp0

SET host=localhost
SET db=gazetteer
IF NOT "%1"=="" SET host=%1

rem SET psql="c:\Program Files\Postgresql\9.0\bin\psql" -h %host% -d %db%
SET psql="psql" -t -h %host% -d %db%

rem set encoding and code page to handle BOM markers
rem Tried chcp 65001 to change code page, but resulted in time out error.
SET PGCLIENTENCODING=UTF8

set logfile=load_%host%.log

IF "%2"=="" GOTO restart
echo =========================================== >> %logfile%
echo Restarting >> %logfile%
date /t >> %logfile%
time /t >> %logfile%

IF "%2"=="reprocess" GOTO reproc
IF "%2"=="install" GOTO install
echo Don't understand command
echo Don't understand command %2 >> %logfile%
GOTO done

:restart
echo Reloading gazetteer migration into %host% > %logfile%
date /t >> %logfile%
time /t >> %logfile%

echo Creating the gazetteer_import schema
echo Creating the gazetteer_import schema >> %logfile% 2>&1
%psql% -c "drop schema gazetteer_import cascade" >>%logfile% 2>&1
%psql% -f schema/gazetteer_import_schema.sql >>%logfile% 2>&1
%psql% -f schema/gazetteer_import_refdata.sql >>%logfile% 2>&1
%psql% -f schema/gazetteer_import_functions.sql >>%logfile% 2>&1

echo Load the feature type spreadsheet (create sql, run sql)
echo Load the feature type spreadsheet (create sql, run sql) >>%logfile% 2>&1
python load_ftypes.py >>%logfile% 2>&1
%psql% -f gazetteer_import_ftype.sql >>%logfile% 2>&1

echo Load the migration spreadsheets and GIS data
echo Load the migration spreadsheets and GIS data >>%logfile% 2>&1
python load_migration_data.py %host% >>%logfile% 2>&1
python load_gis_data.py %host% >>%logfile% 2>&1

:reprocess
echo Process the migration data - error checking and installing into import tables
echo Process the migration data - error checking and installing into import tables >>%logfile% 2>&1

%psql% -f import_features.sql >>%logfile% 2>&1
%psql% -f import_feature_geom.sql >>%logfile% 2>&1
%psql% -f import_names.sql >>%logfile% 2>&1
%psql% -f import_name_event.sql >>%logfile% 2>&1
%psql% -f import_name_annot.sql >>%logfile% 2>&1
%psql% -f check_close_names.sql >>%logfile% 2>&1

:install
echo Installing into the gazetteer schema
echo Installing into the gazetteer schema >>%logfile% 2>&1

%psql% -f install_imported_data.sql >>%logfile% 2>&1

:done

