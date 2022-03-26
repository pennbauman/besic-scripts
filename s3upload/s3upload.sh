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
if (( $(find $DATA_DIR -name "*.csv" | wc -l) != 0 )); then
	name="$(date +"%Y%m%d_%H%M%S_%Z")_$(besic-getval mac)"
	zip -j $DATA_DIR/$name.zip $DATA_DIR/*.csv
	rm -f $DATA_DIR/*.csv
fi

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
export S3_ACCESS_KEY="$S3_ACCESS_KEY"
export S3_SECRET_KEY="$S3_SECRET_KEY"

# Get deployment
export MAC="$(besic-getval mac)"

# Upload zip files
if [ -e $HOME/.s3uploading ]; then
	echo "[$(date --rfc-3339=seconds)] Upload already running" >> $LOG
	exit 0
else
	touch $HOME/.s3uploading
	python3 /usr/share/besic/boto3-uploader.py $DATA_DIR $ARCHIVE_DIR >> $LOG
	rm $HOME/.s3uploading
fi
