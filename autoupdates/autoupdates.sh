#!/bin/bash
# BESI-C Automatic Updater
#   https://github.com/besi-c/besic-scripts
#   Penn Bauman <pcb8gb@virginia.edu>

LOG="$(besic-getval log-dir)/autoupdates.log"
mkdir -p $(dirname $LOG)

TMP_DIR=$(mktemp -d)

# check root
if [ $(id -u) -ne 0 ]; then
	echo "must be run as root"
	exit
fi


# Rerun updates until complete
while [ true ]; do
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

	# Wait if router to allow others to update
	if [ $(command -v besic-router) ]; then
		sleep $((30*60))
	fi

	# Reboot device
	echo "[$(date --rfc-3339=seconds)] Restarting ..." >> $LOG
	reboot
done

