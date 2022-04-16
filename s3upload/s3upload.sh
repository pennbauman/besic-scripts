#!/bin/bash
# BESI-C Relay Data Upload
#   https://github.com/pennbauman/besic-debs
#   Penn Bauman <pcb8gb@virginia.edu>

DATA_DIR="$(besic-getval data-dir)"
ARCHIVE_DIR="$(besic-getval archive-dir)"
LOCK_FILE="/tmp/besic/s3uploading"
mkdir -m 777 -p $ARCHIVE_DIR $(dirname $LOCK_FILE)

LOG="$(besic-getval log-dir)/s3upload.log"
mkdir -p $(dirname $LOG)


# Read settings
export MAC="$(besic-getval mac)"
export S3_BUCKET="$(besic-getval s3-bucket)"
export S3_ACCESS_KEY=$(besic-secret S3_ACCESS_KEY)
export S3_SECRET_KEY=$(besic-secret S3_SECRET_KEY)


# Create zip file
if (( $(find $DATA_DIR -name "*.csv" | wc -l) != 0 )); then
	name="$(date +"%Y%m%d_%H%M%S_%Z")_$MAC"
	zip -j $DATA_DIR/$name.zip $DATA_DIR/*.csv
	rm -f $DATA_DIR/*.csv
fi

# Check zip files exists
if (( $(find $DATA_DIR -name "*.zip" | wc -l) == 0 )); then
	echo "[$(date --rfc-3339=seconds)] No data to uploaded" >> $LOG
	exit
fi


# Upload zip files
if [ -e $LOCK_FILE ]; then
	echo "[$(date --rfc-3339=seconds)] Upload already running" >> $LOG
	exit 0
else
	touch $LOCK_FILE
	python3 /usr/share/besic/boto3-uploader.py $DATA_DIR $ARCHIVE_DIR >> $LOG
	rm $LOCK_FILE
fi
