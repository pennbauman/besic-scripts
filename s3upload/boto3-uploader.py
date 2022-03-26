# BESI-C AWS S3 Data Uploader
#   https://github.com/pennbauman/besic-debs
#   Yudel Martinez <yam3nv@virginia.edu>
#   Penn Bauman <pcb8gb@virginia.edu>
import boto3
import sys
import os
from datetime import datetime, timezone

# Print log
def log(text):
    local_time = datetime.now(timezone.utc).astimezone()
    print("[%s] %s" % (local_time.isoformat(" ", "seconds"), text), flush=True)


# Check environment variables
if not os.getenv('MAC'):
    print("Missing MAC")
    sys.exit(1)
if not os.getenv('S3_ACCESS_KEY'):
    print("Missing S3_ACCESS_KEY")
    sys.exit(1)
if not os.getenv('S3_SECRET_KEY'):
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
session = boto3.Session(aws_access_key_id=os.getenv('S3_ACCESS_KEY'),
        aws_secret_access_key=os.getenv('S3_SECRET_KEY'))
s3 = session.resource('s3')

# Upload loop
last_success = True
for upfile in os.listdir(updir):
    if not upfile.endswith(".zip"):
        continue
    try:
        # Upload zip file
        aws_path = "relays/" + os.getenv('MAC') + "/" + upfile
        with open(os.path.join(updir, upfile), "rb") as data:
            s3.Bucket("besi-c").put_object(Key=aws_path, Body=data)
        os.rename(os.path.join(updir, upfile), os.path.join(archivedir, upfile))
        log("%s uploaded" % os.path.basename(upfile))
        last_success = True
    except Exception as e:
        log("%s uploaded failed\n%s" % (os.path.basename(upfile), e))
        if last_success:
            last_success = False
        else:
            sys.exit(1)