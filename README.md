# BESI-C Script Packages
Various bash and python scripts for use on BESI-C devices


## Build Packages
Install build dependencies

	sudo apt-get -y install devscripts debhelper libbesic-tools python3 python3-boto3 bash coreutils bluez zip

Then enter package directory and build package

	cd [package]
	debuild -uc -us
