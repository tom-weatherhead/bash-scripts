#!/bin/bash

# ip_addr_win.sh : Print the IPv4 addresses, MAC addresses, and descriptions of all active network interfaces, listed in their preferred order.

# Hexadecimal digit: [0-9a-fA-F] -> [[:xdigit:]]

netstat -rn | perl -nle 'print "$1 = $2 = $5" if /^( {1,2}[0-9]{1,2})\.{3}(([[:xdigit:]]{2} ){5}([[:xdigit:]]{2})) \.+(.+)$/' | sort -k1,3 | perl -nle 'print $1 if /^.{6}(.{17})/' | tr [a-f\ ] [A-F-] | while read -r line; do
	ipconfig /all | grep -e Description -e Physical -e IPv4 | perl -nle 'sub word_up { my $A=shift; print "$A = $P = $D"; $P=$D=""; } word_up $1 if /^ +IPv4 Address.+: (.+)[$(]/ ; $D=$1 if /^ +Description.+: (.+)$/ ; $P=$1 if /^ +Physical.+: (.+)$/' | grep $line
done
