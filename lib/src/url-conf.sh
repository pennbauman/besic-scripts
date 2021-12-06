#!/bin/bash
# BESI-C URL Config Reader
#   https://github.com/pennbauman/besic-basestation
#   Penn Bauman <pcb8gb@virginia.edu>

CONF_FILE="/etc/besic/url.conf"


# Read config if it exists
if [ -e $CONF_FILE ]; then
	source $CONF_FILE
fi

# Export URL env var
if [ -z $API_URL ]; then
	# Default value
	export API_URL="http://api.besic.org"
else
	export API_URL="$API_URL"
fi
echo $API_URL
