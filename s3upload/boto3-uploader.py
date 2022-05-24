# BESI-C AWS S3 File Uploader
#   https://github.com/besi-c/besic-scripts
#   Yudel Martinez <yam3nv@virginia.edu>
#   Penn Bauman <pcb8gb@virginia.edu>
import boto3
import sys
import os
from datetime import datetime, timezone
import besic

# Print log
def log(text):
    local_time = datetime.now(timezone.utc).astimezone()
    print("[%s] %s" % (local_time.isoformat(" ", "seconds"), text), flush=True)


# Check environment variables
if not besic.secret('S3_ACCESS_KEY'):
    print("Missing S3_ACCESS_KEY")
    sys.exit(1)
if not besic.secret('S3_SECRET_KEY'):
    print("Missing S3_SECRET_KEY")
    sys.exit(1)


# Check file to upload
if len(sys.argv) < 2:
    print("Missing upload directory")
    sys.exit(2)
if len(sys.argv) < 3:
    print("Missing archive directory")
    sys.exit(2)
updir = sys.argv[1]
archivedir = sys.argv[2]

# Setup uploader
session = boto3.Session(aws_access_key_id=besic.secret('S3_ACCESS_KEY'),
        aws_secret_access_key=besic.secret('S3_SECRET_KEY'))
s3 = session.resource('s3')

# Upload loop
last_success = True
files = os.listdir(updir)
files.sort()
for upfile in files:
    if not upfile.endswith(".zip"):
        continue
    try:
        # Upload zip file
        aws_path = besic.device_mac() + "/" + upfile
        with open(os.path.join(updir, upfile), "rb") as data:
            s3.Bucket(besic.s3_bucket()).put_object(Key=aws_path, Body=data)
        # Archive zip file
        os.rename(os.path.join(updir, upfile), os.path.join(archivedir, upfile))
        log(os.path.basename(upfile) + " uploaded")
        last_success = True
    except Exception as e:
        log(os.path.basename(upfile) + " uploaded failed\n" + str(e))
        if last_success:
            last_success = False
        else:
            log("Upload cancelled")
            sys.exit(1)
