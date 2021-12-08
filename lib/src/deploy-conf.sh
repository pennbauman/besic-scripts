#!/bin/bash
# BESI-C Deplyoment Config Reader
#   https://github.com/pennbauman/besic-debs
#   Penn Bauman <pcb8gb@virginia.edu>

CONF_FILE="/var/besic/deploy.conf"


# Read config if it exists
if [ -e $CONF_FILE ]; then
	source $CONF_FILE
fi

# Export DEPLOYMENT_NAME env var
if [ -z $DEPLOYMENT_NAME ]; then
	# Default value
	export DEPLOYMENT_NAME="undeployed"
else
	export DEPLOYMENT_NAME="$DEPLOYMENT_NAME"
fi

# Export RELAY_ID env var
if [ -z $RELAY_ID ]; then
	# Default value
	export RELAY_ID="0"
else
	export RELAY_ID="$RELAY_ID"
fi