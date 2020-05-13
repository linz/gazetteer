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

$psql -f gaz_add_config.sql
python install_web_config.py $params
