#!/bin/bash

# See https://askubuntu.com/questions/151958/how-to-make-dhclient-forget-its-last-dhcp-lease

# This script must be run as root.
# if uid != 0 then error_exit "..."

# Beware of the error message: RTNETLINK answers: File exists

WIFI_INTERFACE=wlp2s3

# sudo rm /var/lib/dhcp/dhclient.* (or dhclient.leases + dhclient.${WIFI_INTERFACE}.leases)
# sudo rm /run/network/ifstate.$WIFI_INTERFACE
# sudo rm /run/wpa_supplicant.${WIFI_INTERFACE}.pid

dhclient -r -v $WIFI_INTERFACE
# ifdown $WIFI_INTERFACE
rm /var/lib/dhcp/dhclient.*
service networking stop
rm -f /run/network/ifstate.$WIFI_INTERFACE
service networking start
# ifup -v $WIFI_INTERFACE
dhclient -v $WIFI_INTERFACE
ping -c4 8.8.8.8				# Ping a DNS server (?) by its raw IPv4 address, not its name
ping -c4 www.google.com
