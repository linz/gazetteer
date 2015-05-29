#!/bin/bash

params=""
gdb="gazetteer"
host="local"
drop=0

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

if [ "$hostd" = local ] ; then
	hostd=/var/run/postgresql
fi

params="$params -d $gdb -h $hostd"
psql="psql $params"

echo "host: $host"
echo "database: $gdb"
echo "Using $psql"

export PGCLIENTENCODING=UTF8

if [ "$1" = drop ]; then
	echo "Dropping existing gazetter schema"
	$psql -c 'drop schema gazetteer_history cascade'
	$psql -c 'drop schema gazetteer cascade'
	echo "Creating the gazetteer schema"
	echo "Assumes that the gazetteer database and roles have already been created"
	$psql -f gazetteer_schema.sql 
	$psql -f gazetteer_app_schema.sql 
	$psql -f gazetteer_sysdata_init.sql 
        $psql -f gazetteer_history.sql 
        $psql -f gazetteer_sysdata.sql 
        $psql -f gazetteer_export_schema.sql 
fi

$psql -f gazetteer_functions.sql 
$psql -f gazetteer_geometry_views.sql 
$psql -f gazetteer_text_search.sql 
$psql -f gazetteer_search_function.sql 
$psql -f gazetteer_add_user.sql
$psql -f gazetteer_app_funcs.sql 
$psql -f gazetteer_app_sysdata.sql 
$psql -f gazetteer_triggers.sql 

python build_gazetteer_export.py
$psql -f gazetteer_export.sql
$psql -f gazetteer_export_func.sql
# Cannot run this till after gazetteer_web schema installed
# $psql -f gazetteer_reload_web.sql 
$psql -f gazetteer_grant.sql 
