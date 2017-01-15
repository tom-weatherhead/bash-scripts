#!/bin/bash

# echo

# ipconfig /all | grep -e Description -e Physical -e IPv4 | perl -nle 'sub outp { my $A=shift; print "$A = $P = $D"; $P=$D=""; } outp $1 if /^\s+IPv4 Address.+\:\s(.+)[$(]/ ; $D=$1 if /^\s+Description.+\:\s(.+)$/ ; $P=$1 if /^\s+Physical.+\:\s(.+)$/'

# echo

# netstat -rn | perl -nle 'print "$1 = $2 = $5" if /^(\s{1,2}[0-9]{1,2})\.{3}(([0-9a-fA-F]{2}\s){5}([0-9a-fA-F]{2}))\s\.+(.+)$/' | sort -k1,3 | perl -nle 'print "$1" if /^.{6}(.{17})/' | tr [a-f\ ] [A-F-]

# echo

netstat -rn | perl -nle 'print "$1 = $2 = $5" if /^(\s{1,2}[0-9]{1,2})\.{3}(([0-9a-fA-F]{2}\s){5}([0-9a-fA-F]{2}))\s\.+(.+)$/' | sort -k1,3 | perl -nle 'print "$1" if /^.{6}(.{17})/' | tr [a-f\ ] [A-F-] | while read -r line ; do
	ipconfig /all | grep -e Description -e Physical -e IPv4 | perl -nle 'sub outp { my $A=shift; print "$A = $P = $D"; $P=$D=""; } outp $1 if /^\s+IPv4 Address.+\:\s(.+)[$(]/ ; $D=$1 if /^\s+Description.+\:\s(.+)$/ ; $P=$1 if /^\s+Physical.+\:\s(.+)$/' | grep $line
done
