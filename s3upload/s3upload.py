#!/usr/bin/python3
# BESI-C AWS S3 File Uploader
#   https://github.com/besi-c/besic-scripts
#   Yudel Martinez <yam3nv@virginia.edu>
#   Penn Bauman <pcb8gb@virginia.edu>
import boto3
import sys
import os
from zipfile import ZipFile
from datetime import datetime, timezone
import besic

DATA_DIR = besic.data_dir()
LOCK_FILE = "/tmp/besic-s3uploading"


# Print log
def log(text):
    local_time = datetime.now(timezone.utc).astimezone()
    with open(os.path.join(besic.log_dir(), "s3upload.log"), "a") as f:
        f.write("[%s] %s\n" % (local_time.isoformat(" ", "seconds"), text))


# Check for CSV data files
csv_files = []
for f in os.listdir(DATA_DIR):
    if f.endswith(".csv"):
        csv_files.append(f)

# Create ZIP file if data files exist
if not csv_files:
    log("No data to zip")
else:
    local_time = datetime.now(timezone.utc).astimezone()
    zip_path = "%s_%s.zip" % (local_time.strftime("%Y%m%d_%H%M%S_%Z"), besic.device_mac())
    with ZipFile(os.path.join(DATA_DIR, zip_path), "x") as z:
        for f in csv_files:
            z.write(os.path.join(DATA_DIR, f), f)
            os.remove(os.path.join(DATA_DIR, f))


# Create lock to prevent overlapping uploads
if os.path.isfile(LOCK_FILE):
    log("Upload already running")
    sys.exit(0)
else:
    open(LOCK_FILE, 'a').close()


# Check S3 secrets variables
if not besic.secret('S3_ACCESS_KEY'):
    print("Missing S3_ACCESS_KEY")
    os.remove(LOCK_FILE)
    sys.exit(1)
if not besic.secret('S3_SECRET_KEY'):
    print("Missing S3_SECRET_KEY")
    os.remove(LOCK_FILE)
    sys.exit(1)


# Setup uploader
session = boto3.Session(aws_access_key_id=besic.secret('S3_ACCESS_KEY'),
        aws_secret_access_key=besic.secret('S3_SECRET_KEY'))
s3 = session.resource('s3')

# Upload loop
last_success = True
files = os.listdir(DATA_DIR)
files.sort()
for upfile in files:
    if not upfile.endswith(".zip"):
        continue
    try:
        # Upload zip file
        aws_path = besic.device_mac() + "/" + upfile
        with open(os.path.join(DATA_DIR, upfile), "rb") as data:
            s3.Bucket(besic.s3_bucket()).put_object(Key=aws_path, Body=data)
        # Remove zip file
        os.remove(os.path.join(DATA_DIR, upfile))
        log(os.path.basename(upfile) + " uploaded")
        last_success = True
    except Exception as e:
        log(os.path.basename(upfile) + " upload failed\n" + str(e))
        # Check for repeated failures
        if last_success:
            last_success = False
        else:
            log("Upload cancelled")
            os.remove(LOCK_FILE)
            sys.exit(1)

# Release lock
os.remove(LOCK_FILE)
