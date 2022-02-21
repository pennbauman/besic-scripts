# BESI-C AWS S3 Data Uploader
#   https://github.com/pennbauman/besic-debs
#   Yudel Martinez <yam3nv@virginia.edu>
#   Penn Bauman <pcb8gb@virginia.edu>
import boto3
import sys
import os


# Check environment variables
if not os.getenv('DEPLOYMENT_NAME'):
    print("Missing DEPLOYMENT_NAME")
    sys.exit(1)
if not os.getenv('RELAY_ID'):
    print("Missing RELAY_ID")
    sys.exit(1)
if not os.getenv('S3_ACCESS_KEY'):
    print("Missing S3_ACCESS_KEY")
    sys.exit(1)
if not os.getenv('S3_SECRET_KEY'):
    print("Missing S3_SECRET_KEY")
    sys.exit(1)


# Check file to upload
if len(sys.argv) < 2:
    print("Missing file to upload")
    sys.exit(2)
upfile = sys.argv[1]
aws_path = os.getenv('DEPLOYMENT_NAME') + "/Relays/" + os.getenv('RELAY_ID') + "/" + upfile.split("/")[-1]

# Setup uploader
session = boto3.Session(aws_access_key_id=os.getenv('S3_ACCESS_KEY'),
        aws_secret_access_key=os.getenv('S3_SECRET_KEY'))
s3 = session.resource('s3')

# Upload
try:
    with open(upfile, "rb") as data:
        s3.Bucket("besi-c").put_object(Key=aws_path, Body=data)
    sys.exit(0)
except Exception as e:
    print(e)
    sys.exit(1)
