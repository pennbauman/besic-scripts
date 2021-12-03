#!/bin/bash
# BESI-C Heartbeat
#   https://github.com/pennbauman/besic-debs
#   Penn Bauman <pcb8gb@virginia.edu>

DIR="/var/besic"

LOG="/var/log/besic/heartbeat.log"
mkdir -p $(dirname LOG)


# read configurations
source besic-url-conf
err=$(source besic-dev-conf)
if [ $? -ne 0 ]; then
	echo "[$(date --rfc-3339=seconds)] $err" >> $LOG
	exit 1
fi

# make heartbeat calls
fail=0
i=0
while (( $i < 10 )); do
	res=$(curl "$API_URL/device/heartbeat" -d "mac=$MAC" -d "password=$PASSWORD")
	if [[ $res != "Success" ]]; then
		fail=$(($fail + 1))
		if [[ $res == "Unknown device" ]]; then
			curl "$API_URL/device/new" -d "mac=$MAC" -d "password=$PASSWORD" -d "type=___"
		fi
	fi
	sleep 5
	i=$(($i + 1))
done

# log failures if any
if (( $fail > 1 )); then
	echo "[$(date --rfc-3339=seconds)] $fail heartbeats failed ($res)" >> $LOG
elif (( $fail > 0 )); then
	echo "[$(date --rfc-3339=seconds)] 1 heartbeat failed ($res)" >> $LOG
fi
