#!/bin/bash
# BESI-C Device Config Reader
#   https://github.com/pennbauman/besic-debs
#   Penn Bauman <pcb8gb@virginia.edu>

CONF_FILE="/var/besic/device.conf"


# Read config if it exists
if [ -e $CONF_FILE ]; then
	source $CONF_FILE
else
	# Create config file if it doesn't exists
	mkdir -p $(dirname $CONF_FILE)

	MAC="$(sed 's/://g' /sys/class/net/wlan0/address)"
	echo "MAC=\"$MAC\"" > $CONF_FILE

	PASSWORD=$(openssl rand -hex 32)
	echo "PASSWORD=\"$PASSWORD\"" >> $CONF_FILE
fi

# Export MAC env var or thow error
if [ -z $MAC ]; then
	echo "MAC not found"
	exit 1
else
	export MAC="$MAC"
fi

# Export PASSWORD env var or thow error
if [ -z $PASSWORD ]; then
	echo "PASSWORD not found"
	exit 1
else
	export PASSWORD="$PASSWORD"
fi
