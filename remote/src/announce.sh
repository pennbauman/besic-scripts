#!/bin/bash
# BESI-C Heartbeat
#   https://github.com/pennbauman/besic-debs
#   Penn Bauman <pcb8gb@virginia.edu>

DIR="/var/besic"
TYPE_CONF="/etc/besic/type.conf"

LOG="/var/log/besic/announce.log"
mkdir -p $(dirname LOG)


# read configurations
source besic-url-conf
err=$(source besic-dev-conf)
if [ $? -ne 0 ]; then
	echo "[$(date --rfc-3339=seconds)] $err" >> $LOG
	exit 1
fi

# Get device type
if [ ! -e $TYPE_CONF ]; then
	source $TYPE_CONF
else
	echo "[$(date --rfc-3339=seconds)] Missing DEVICE_TYPE" >> $LOG
	exit 1
fi

# Initialize basestation on remote server
while true; do
	res=$(curl -s "$API_URL/device/new" -d "mac=$MAC" -d "password=$PASSWORD" -d "type=$DEVICE_TYPE")
	if [[ $res == "Success" ]]; then
		break
	fi
	echo "[$(date --rfc-3339=seconds)]: Remote init failed ($res)" >> $LOG
	sleep 10
done
