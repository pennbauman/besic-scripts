prefix = /usr/local

install:
	mkdir -p $(DESTDIR)$(prefix)/bin
	mkdir -p $(DESTDIR)$(prefix)/share/besic
	install -T s3upload.sh $(DESTDIR)$(prefix)/bin/besic-s3upload
	cp boto3-uploader.py $(DESTDIR)$(prefix)/share/besic
