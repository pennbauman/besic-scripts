# BESI-C Data Uploader for AWS S3
#   https://github.com/besi-c/besic-scripts
#   Penn Bauman <pcb8gb@virginia.edu>
prefix = /usr/local
bindir = $(prefix)/bin
sharedir = $(prefix)/share/besic

install:
	install -m 0755 -d $(DESTDIR)$(bindir)
	install -m 0755 s3upload.sh $(DESTDIR)$(bindir)/besic-s3upload
	install -m 0755 -d $(DESTDIR)$(sharedir)
	install -m 0644 boto3-uploader.py $(DESTDIR)$(sharedir)
