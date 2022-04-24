prefix = /usr/local
bindir = $(prefix)/bin
sharedir = $(prefix)/share/besic

install:
	install -m 0755 -d $(DESTDIR)$(bindir)
	install -m 0755 router.sh $(DESTDIR)$(bindir)/besic-router
	install -m 0755 -d $(DESTDIR)$(sharedir)
	install -m 0644 iptables-eth0.v4 $(DESTDIR)$(sharedir)/iptables-eth0.v4
	install -m 0644 iptables-wlan0.v4 $(DESTDIR)$(sharedir)/iptables-wlan0.v4
