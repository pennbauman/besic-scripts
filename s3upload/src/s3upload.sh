#!/bin/bash
# BESI-C Relay Data Upload
#   https://github.com/pennbauman/besic-debs
#   Penn Bauman <pcb8gb@virginia.edu>

DATA_DIR="/var/besic/data"
ARCHIVE_DIR="/var/besic/archive"
KEY_FILE="/var/besic/s3key.conf"
mkdir -p $ARCHIVE_DIR

LOG="/var/log/besic/s3upload.log"
mkdir -p $(dirname LOG)


# Create zip file
name="$(date +"%Y%m%d_%H%m%S_%Z")_$(/usr/bin/uuid)"
zip $DATA_DIR/$name.zip $DATA_DIR/*.csv
rm -f $DATA_DIR/*.csv

# Check zip files exists
if (( $(find $DATA_DIR -name "*.zip" | wc -l) == 0 )); then
	echo "[$(date --rfc-3339=seconds)] No data to uploaded" >> $LOG
	exit
fi

# Read keys
if [ -e $KEY_FILE ]; then
	source $KEY_FILE
else
	echo "[$(date --rfc-3339=seconds)] Missing S3 keys" >> $LOG
	exit 1
fi

# Get deployment
source besic-deploy-conf

# Upload zip files
for f in $DATA_DIR/*.zip; do
	err=$(python3 /usr/share/besic/boto3-uploader.py $f)
	if (( $? != 0 )); then
		echo "[$(date --rfc-3339=seconds)] $(basename $f) upload failed" >> $LOG
		echo "$err" >> $LOG
	else
		echo "[$(date --rfc-3339=seconds)] $(basename $f) uploaded" >> $LOG
		mv $f $ARCHIVE_DIR
	fi
done
