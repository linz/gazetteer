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

if [ "$hostd" = local ]; then
	hostd=/var/run/postgresql
fi

dparams="$params -h $hostd"
params="$params -d $gdb -h $hostd"
psql="psql $params"

echo "host: $host"
echo "database: $gdb"
echo "Using $psql"

export PGCLIENTENCODING=UTF8

# Extract the current web configuration information if available

datetime=$(date +"%Y%m%d%H%M")
pg_dump $dparams -t gazetteer_web.gaz_web_config -a $gdb > gaz_web_config_dump_$host.$datetime.psql

$psql -c "select gazetteer.gweb_update_web_database()"
