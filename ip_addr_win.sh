#!/bin/bash

# ip_addr_win.sh : Print the IPv4 addresses, MAC addresses, and descriptions of all active network interfaces, listed in their preferred order.

# 2017/01/14 : The current version of this script works on Cygwin; it uses Windows' netstat.
# TODO: Write a version of the script that runs on Ubuntu, and then combine the two versions, using $(uname -o) to identify the current platform.

# Ubuntu's netstat man page:
# "This program is mostly obsolete. Replacement for netstat is ss. Replacement for netstat -r is ip route. Replacement for netstat -i is ip -s link. Replacement for netstat -g is maddr."

# Perl regular expression charcter classes:
# See https://www.google.ca/search?q=perl+regex+classes
# See http://perldoc.perl.org/perlrecharclass.html
# Hexadecimal digit: [0-9a-fA-F] -> [[:xdigit:]]

# 2017/01/16 : Google "linux netstat" and look for "10 basic examples of linux netstat command" on www.binarytides.com
# Google "windows 10 bash netstat" and look for:
#   - "Running Nginx on Bash for Windows 10" on www.svennd.be
#   - "First look: Hands on with Ubuntu on Windows 10" on www.extremetech.com -> Includes a link to a 99-line .bashrc file
#     - WSL's "netstat can't find the devices it expects under /proc, so it doesn't report much."
#   - "Everything You Can Do With Windows 10's New Bash Shell" on www.howtogeek.com

netstat -rn | perl -nle 'print "$1 = $2 = $5" if /^( {1,2}[0-9]{1,2})\.{3}(([[:xdigit:]]{2} ){5}([[:xdigit:]]{2})) \.+(.+)$/' | sort -k1,3 | perl -nle 'print $1 if /^.{6}(.{17})/' | tr [a-f\ ] [A-F-] | while read -r line; do
	ipconfig /all | grep -e Description -e Physical -e IPv4 | perl -nle 'sub word_up { my $A=shift; print "$A = $P = $D"; $P=$D=""; } word_up $1 if /^ +IPv4 Address.+: (.+)[$(]/ ; $D=$1 if /^ +Description.+: (.+)$/ ; $P=$1 if /^ +Physical.+: (.+)$/' | grep $line
done
