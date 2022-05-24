#!/bin/bash

LOG="/var/log/besic/autoupdates.log"
DIR="/var/besic"
TMP_DIR=$(mktemp -d)

# check root
if [ $(id -u) -ne 0 ]; then
	echo "must be run as root"
	exit
fi


while 1; do
	apt-get update &>> $LOG
	code=$?
	if [[ $code != 0 ]]; then
		echo "[$(date --rfc-3339=seconds)] apt-get update failed ($code)" >> $LOG
		sleep 60
		continue
	fi

	# Update if available
	if [[ $(apt-get -s upgrade -V | grep '=>' | wc -l) != 0 ]]; then
		apt-get -y upgrade &>> $LOG
		code=$?
		if [[ $code != 0 ]]; then
			echo "[$(date --rfc-3339=seconds)] apt-get upgrade failed ($code)" >> $LOG
			sleep 60
			continue
		fi
		echo "[$(date --rfc-3339=seconds)] Updated Raspberry Pi OS" >> $LOG
	fi

	if [ $(command -v besic-router) ]; then
		sleep $((30*60))
	fi


	echo "[$(date --rfc-3339=seconds)] Restarting ..." >> $LOG
	reboot
done

