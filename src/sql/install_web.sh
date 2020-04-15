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
params="$params -d $gdb -h $hostd --set ON_ERROR_STOP=1"
psql="psql $params"

echo "host: $host"
echo "database: $gdb"
echo "Using $psql"

export PGCLIENTENCODING=UTF8

sleep 15

if [ "$1" = drop ] ; then

	HAS_CONFIG=`$psql -XAt <<EOF
SELECT count(c.oid)
FROM pg_class c, pg_namespace n
WHERE n.nspname = 'gazetteer_web'
  AND c.relnamespace = n.oid
  AND c.relname = 'gaz_web_config'
EOF
`
	test $? = 0 || {
		echo "Error querying for existing web config" >&2
		exit 1
	}
	if test "$HAS_CONFIG" = 1; then
		datetime=$(date +"%Y%m%d%H%M")
		# TODO: avoid overriding an existing dump!
		configfile="gaz_web_config_dump_$host.$datetime.psql"
		echo "Extracting current gazetter web config to $configfile"
		pg_dump $dparams -t gazetteer_web.gaz_web_config -a $gdb > $configfile || exit 1
	fi

	echo "Dropping existing gazetter schema"
	$psql -c 'drop schema if exists gazetteer_web cascade'

	echo "Creating the gazetteer schema"
	echo "Assumes that the gazetteer database and roles have already been created"
	$psql -f gazetteer_web_schema.sql  || exit 1

	# Restore the web configuration
	echo "Restoring web configuration"
	if test "$HAS_CONFIG" = 1; then
		$psql -f $configfile || exit 1
	fi
fi

$psql -f gazetteer_web_functions.sql  || exit 1
$psql -f gazetteer_reload_web.sql  || exit 1
$psql -f gazetteer_grant.sql || exit 1

# $psql -c "select gazetteer.gweb_update_web_database()"
