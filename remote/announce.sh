#!/bin/bash
# BESI-C Heartbeat
#   https://github.com/pennbauman/besic-debs
#   Penn Bauman <pcb8gb@virginia.edu>

DIR="/var/besic"
TYPE_CONF="/etc/besic/type.conf"

LOG="/var/log/besic/announce.log"
mkdir -p $(dirname LOG)


API_URL="$(besic-getval api-url)"
TYPE="$(besic-getval type)"
MAC="$(besic-getval mac)"
PASSWORD="$(besic-getval password)"


# Initialize basestation on remote server
while true; do
	res=$(curl -s "$API_URL/device/new" -d "mac=$MAC" -d "password=$PASSWORD" -d "type=$TYPE")
	if [[ $res == "Success" ]]; then
		break
	fi
	echo "[$(date --rfc-3339=seconds)] Remote init failed ($res)" >> $LOG
	sleep 10
done
echo "[$(date --rfc-3339=seconds)] Remote init successful" >> $LOG
