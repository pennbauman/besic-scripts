# BESI-C APT Packages
Available at [apt.besic.org](http://apt.besic.org)


## makedeb
These packages are built with makedeb. makedeb is a tool to create .deb packages from PKGBUILD files. More information can be found at [makedeb.hunterwittenborn.com](https://makedeb.hunterwittenborn.com/home/introduction/).

### Install
Add signing key

	wget -qO - 'https://proget.hunterwittenborn.com/debian-feeds/makedeb.pub' | gpg --dearmor | sudo tee /usr/share/keyrings/makedeb-archive-keyring.gpg &> /dev/null

Add repository

	echo 'deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.hunterwittenborn.com/ makedeb main' | sudo tee /etc/apt/sources.list.d/makedeb.list

Install package

	sudo apt update
	sudo apt install makedeb

### Usage
When in a directory containing a PKGBUILD file, simply run `makedeb` to build the package.
