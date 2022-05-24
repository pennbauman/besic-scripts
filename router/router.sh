#!/bin/bash
# BESI-C Router Periodic Setup Script
#   https://github.com/besi-c/besic-scripts
#   Penn Bauman <pcb8gb@virginia.edu>

LOG="$(besic-getval log-dir)/router.log"
mkdir -p $(dirname $LOG)

if [[ $# == 0 ]] || [[ $1 =~ ^-*[hH](elp|ELP|)$ ]]; then
	echo "BESI-C Router Tool"
	echo ""
	echo "Usage: besic-router [command]" # [options]
	echo ""
	echo "Commands"
	echo "  status    Check router and dependencies status"
	echo "  config    Configure router dependencies (in /etc)"
	#echo "  cleanup   Cleanup configuration in /etc"
	echo "  iptables  Setup iptables for router based on available interfaces"
	exit 0
fi

if [[ $1 == "status" ]]; then
	# iptables
	arp -a
	# dnsmasq, hostapd, dhcpcd
	systemctl status dnsmasq | head -n 3
	systemctl status hostapd | head -n 3
	systemctl status dhcpcd | head -n 3
	systemctl status besic-router | head -n 3
	#echo "TODO"
	exit 0
elif [[ $1 == "config" ]]; then
	if [ -e /etc/hostapd/besic.conf ]; then
		if [[ $(grep '### BESI-C ROUTER CONFIG ###' /etc/hostapd/besic.conf | wc -l) == 0 ]]; then
			echo "Conflicting /etc/hostapd/hostapd.conf already exists"
			exit 1
		fi
	else
		mkdir -p /etc/hostapd
		source /etc/besic/router.conf
		if [[ $ROUTER_SSID == "" ]]; then
			echo "Missing $$ROUTER_SSID"
		fi
		if [[ $ROUTER_PSWD == "" ]]; then
			echo "Missing $$ROUTER_PSWD"
		fi
		echo "### BESI-C ROUTER CONFIG ###
interface=wlan1
driver=nl80211
ssid=$ROUTER_SSID
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$ROUTER_PSWD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMPi
### DO NOT EDIT ###" > /etc/hostapd/besic.conf
		echo "/etc/hostapd/besic.conf setup"
	fi

#elif [[ $1 == "cleanup" ]]; then
	#echo "TODO"
	#exit 1
elif [[ $1 == "iptables" ]]; then
	if [[ $(grep "eth0" /proc/net/route | wc -l) != 0 ]]; then
		if [[ $(iptables-save | sed '/^-A POSTROUTING -o eth0 -j MASQUERADE$/!d' | wc -l) == 0 ]]; then
			iptables-restore /usr/share/besic/iptables-eth0.v4
			echo "[$(date --rfc-3339=seconds)] eth0 iptables loaded" >> $LOG
			echo "eth0 iptables setup"
		else
			echo "eth0 iptables already setup"
		fi
	elif [[ $(grep "wlan0" /proc/net/route | wc -l) != 0 ]]; then
		if [[ $(iptables-save | sed '/^-A POSTROUTING -o wlan0 -j MASQUERADE$/!d' | wc -l) == 0 ]]; then
			iptables-restore /usr/share/besic/iptables-wlan0.v4
			echo "[$(date --rfc-3339=seconds)] wlan0 iptables loaded" >> $LOG
			echo "wlan0 iptables setup"
		else
			echo "wlan0 iptables already setup"
		fi
	else
		echo "[$(date --rfc-3339=seconds)] No network connection" >> $LOG
		echo "No network connection"
	fi
	exit 0
else
	echo "Unknown command '$1'"
	exit 1
fi
