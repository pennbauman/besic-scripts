#!/bin/bash
# BESI-C Heartbeat
#   https://github.com/pennbauman/besic-debs
#   Penn Bauman <pcb8gb@virginia.edu>

DEPLOY_CONF="/var/besic/deploy.conf"

TMP="$(mktemp)"
LOG="/var/log/besic/update.log"
mkdir -p $(dirname LOG)


# read configurations
source besic-url-conf
source besic-dev-conf
if [ $? -ne 0 ]; then
	echo "[$(date --rfc-3339=seconds)] Device configuration failed" >> $LOG
	exit 1
fi

curl -s "$API/device/deployment" -d "mac=$MAC" -d "password=$PASSWORD" > $TMP
if [[ $(cat $TMP) =~ DEPLOYMENT ]]; then
	mv $TMP $DEPLOY_CONF
	echo "[$(date --rfc-3339=seconds)] Deployment conf updated" >> $LOG
else
	echo "[$(date --rfc-3339=seconds)] Invalid deployment conf" >> $LOG
	cat $TMP >> $LOG
fi
