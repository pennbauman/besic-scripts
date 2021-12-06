#!/bin/bash
# BESI-C Start Bluetooth Beacon
#   https://github.com/pennbauman/besic-debs
#   Yudel Martinez <yam3nv@virginia.edu>
#   Penn Bauman <pcb8gb@virginia.edu>

LOG="/var/log/besic/beacon.log"
mkdir -p $(dirname LOG)


# Determine ID
source besic-deploy-conf
if [ -z $RELAY_ID ] || [[ $RELAY_ID == 0 ]]; then
	source besic-dev-conf
	id=${MAC: -2}
else
	id=$(printf "%02d" $RELAY_ID)
fi

# Setup beacon if ID is valid
if [[ $id =~ [0-9a-fA-F][0-9a-fA-F] ]]; then
	# Configure the bluetooth module
	hciconfig hci0 down
	hciconfig hci0 up
	hciconfig hci0 leadv 3
	hciconfig hci0 noscan

	# Beacon values
	uuid="B9 40 7F 30 F5 F8 46 6E AF F9 25 55 6B 57 FE 6D"
	major="00 $id"
	minor="BE 51"

	# Start bluetooth beacon
	hcitool -i hci0 cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 $uuid $major $minor C8 00
	echo "[$(date --rfc-3339=seconds)]: Started beacon with ID 0x$id" >> $LOG
else
	echo "[$(date --rfc-3339=seconds)]: Invalid beacon ID '$id'" >> $LOG
	echo "> RELAY_ID='$RELAY_ID' MAC='$MAC'" >> $LOG
fi
