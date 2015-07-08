#!/bin/bash
dev="host=localhost database=gazetteer user=<dev_user> password=<dev_pass>"
uat="host=<uat_host> database=gazetteer user=<uat_user> password=<uat_pass>"
prod="host=<prod_host> database=gazetteer user=<prod_user> password=<prod_pass>"
env=${!1}
if [ -z "$env" ]; then 
	echo "Available environments dev, uat, prod"
	env="show" 
fi
python NZGBplugin/LINZ/gazetteer/gui/DatabaseConfiguration.py $env
