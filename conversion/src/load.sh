#!/bin/bash

params=""
gdb="gazetteer"
host="local"

while [[ $1 == -* ]] ; do
	if [[ $1 == -h ]] ; then
		host=$2
	elif [[ $1 == -d ]] ; then
		gdb=$2
	else
	    params="$params $1 $2"
	fi
	shift
	shift
done

hostd="$host"

if [ $hostd == 'local' ]; then
	hostd=/var/run/postgresql
fi

params="$params -d $gdb -h $hostd"
logfile="output/load_${host}.log"

echo "logfile: $logfile"
echo "host: $host"
echo "database: $gdb"

psql="psql $params"

echo "Using $psql"
export PGCLIENTENCODING=UTF8

echo "===========================================" >> $logfile
echo "Reloading gazetteer migration into $host" > $logfile
date  >> $logfile

echo "Creating the gazetteer_import schema"
echo "Creating the gazetteer_import schema" >> $logfile
$psql -c "drop schema gazetteer_import cascade" >>$logfile 2>&1
$psql -f schema/gazetteer_import_schema.sql >>$logfile 2>&1
$psql -f schema/gazetteer_import_refdata.sql >>$logfile 2>&1
$psql -f schema/gazetteer_import_functions.sql >>$logfile 2>&1

echo 'Load the feature type spreadsheet (create sql, run sql)'
echo 'Load the feature type spreadsheet (create sql, run sql)' >>$logfile
python load_ftypes.py >>$logfile 2>&1
$psql -f gazetteer_import_ftype.sql >>$logfile 2>&1

echo "Load the migration spreadsheets and GIS data"
echo "Load the migration spreadsheets and GIS data" >>$logfile
python load_status_mapping.py $params >>$logfile 2>&1
python load_migration_data.py $params >>$logfile 2>&1
cat load_migration_data.log >> $logfile
python load_gis_data.py $params >>$logfile 2>&1

echo "Load the merged/superceded name spreadsheet"
echo "Load the merged/superceded name spreadsheet" >>$logfile
python load_superceded.py $params >>$logfile 2>&1

echo "Process the migration data - pass 1 for feature merging"
echo "Process the migration data - pass 1 for feature merging" >>$logfile

$psql -f import_features.sql >>$logfile 2>&1
$psql -f import_names.sql >>$logfile 2>&1
$psql -f import_feature_geom.sql >>$logfile 2>&1

$psql -f merge_close_geom.sql >>$logfile 2>&1
$psql -f merge_matched_names.sql >>$logfile 2>&1

echo "Process the migration data - error checking and installing into import tables"
echo "Process the migration data - error checking and installing into import tables" >>$logfile

$psql -f import_features.sql >>$logfile 2>&1
$psql -f import_names.sql >>$logfile 2>&1
$psql -f import_feature_geom.sql >>$logfile 2>&1
$psql -f import_name_event.sql >>$logfile 2>&1
$psql -f import_name_annot.sql >>$logfile 2>&1
$psql -f check_close_geom.sql >>$logfile 2>&1

echo "Installing into the gazetteer schema"
echo "Installing into the gazetteer schema" >>$logfile 2>&1

$psql -f install_imported_data.sql >>$logfile 2>&1

#echo "Updating web database"

# $psql -c 'select gazetteer.gweb_update_web_database()'  >>$logfile 2>&1

python clean_log.py $logfile
python error_xls.py $params -x output/error_summary.xls
python migration_mapping.py $params > output/migration_mapping.html
less $logfile
