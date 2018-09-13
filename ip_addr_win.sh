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

# ThAW 2017/03/18 : Regular expressions: Instead of ending with (.+)$ , I now prefer to end with (.+?)[\r]?$ to accommodate a possible carriage return (\r) just before the newline (\n). The ipconfig line used to be:

# ipconfig /all | grep -e Description -e Physical -e IPv4 | perl -nle 'sub word_up { my $A=shift; print "$A = $P = $D"; $P=$D=""; } word_up $1 if /^ +IPv4 Address.+: (.+)[$(]/ ; $D=$1 if /^ +Description.+: (.+)$/ ; $P=$1 if /^ +Physical.+: (.+)\r$/' | grep $line

###

# ThAW 2017/03/18 : Use tr to remove carriage returns (\r) : See https://stackoverflow.com/questions/800030/remove-carriage-return-in-unix

# echo 'Using tr to remove carriage returns:'

# netstat -rn | perl -nle 'print "$1 = $2 = $5" if /^( {1,2}[0-9]{1,2})\.{3}(([[:xdigit:]]{2} ){5}([[:xdigit:]]{2})) \.+(.+)$/' | sort -k1,3 | perl -nle 'print $1 if /^.{6}(.{17})/' | tr [a-f\ ] [A-F-] | while read -r line; do
	# ipconfig /all | grep -e Description -e Physical -e IPv4 | tr -d '\r' | perl -nle 'sub word_up { my $A=shift; print "$A = $P = $D"; $P=$D=""; } word_up $1 if /^ +IPv4 Address.+: (.+?)[$(]/ ; $D=$1 if /^ +Description.+: (.+)$/ ; $P=$1 if /^ +Physical.+: (.+)$/' | grep $line
# done

# ... or: Replace tr -d '\r' with sed 's/\r//g' : See https://unix.stackexchange.com/questions/170665/remove-a-carriage-return-with-sed

# echo
# echo 'Using sed to remove carriage returns:'

# netstat -rn | perl -nle 'print "$1 = $2 = $5" if /^( {1,2}[0-9]{1,2})\.{3}(([[:xdigit:]]{2} ){5}([[:xdigit:]]{2})) \.+(.+)$/' | sort -k1,3 | perl -nle 'print $1 if /^.{6}(.{17})/' | tr [a-f\ ] [A-F-] | while read -r line; do
	# ipconfig /all | grep -e Description -e Physical -e IPv4 | sed 's/\r//g' | perl -nle 'sub word_up { my $A=shift; print "$A = $P = $D"; $P=$D=""; } word_up $1 if /^ +IPv4 Address.+: (.+?)[$(]/ ; $D=$1 if /^ +Description.+: (.+)$/ ; $P=$1 if /^ +Physical.+: (.+)$/' | grep $line
# done

# echo
# echo 'With tr and no perl subroutine:'

# netstat -rn | perl -nle 'print "$1 = $2 = $5" if /^( {1,2}[0-9]{1,2})\.{3}(([[:xdigit:]]{2} ){5}([[:xdigit:]]{2})) \.+(.+)$/' | sort -k1,3 | perl -nle 'print $1 if /^.{6}(.{17})/' | tr [a-f\ ] [A-F-] | while read -r line; do
	# ipconfig /all | grep -e Description -e "Physical Address" -e "IPv4 Address" | tr -d '\r' | perl -nle 'if (/^ +IPv4 Address.+: (.+?)[$(]/) { print "$1 = $P = $D"; $P = $D = ""; }; if (/^ +Description.+: (.+)$/) { $D = $1; } ; if (/^ +Physical.+: (.+)$/) { $P = $1; };' | grep $line
# done

# echo
# echo 'No tr or sed; just perl:'

# netstat -rn | perl -nle 'print "$1 = $2 = $5" if /^( {1,2}[0-9]{1,2})\.{3}(([[:xdigit:]]{2} ){5}([[:xdigit:]]{2})) \.+(.+)$/' | sort -k1,3 | perl -nle 'print $1 if /^.{6}([0-9a-fA-F ]{17})/' | tr [a-f\ ] [A-F-] | while read -r line; do
	# ipconfig /all | grep -e Description -e "Physical Address" -e "IPv4 Address" | perl -nle 's/\r//g; if (/^ +IPv4 Address.+: (.+)[$(]/) { print "$1 = $P = $D"; $P = $D = ""; } elsif (/^ +Description.+: (.+)$/) { $D = $1; } elsif (/^ +Physical.+: (.+)$/) { $P = $1; }' | grep $line
# done

if [ $(uname -o) = "Cygwin" ]; then
	# 2017/07/08 : Evaluate the "ipconfig /all ..." command only once:

	# echo

	# TODO: On Linux, get the same result using "ip" rather that Windows' "ipconfig".
	IP_INFO=$(ipconfig /all | grep -e Description -e "Physical Address" -e "IPv4 Address" | perl -nle 's/\r//g; if (/^ +IPv4 Address.+: (.+)[$(]/) { print "$1 = $P = $D"; $P = $D = ""; } elsif (/^ +Description.+: (.+)$/) { $D = $1; } elsif (/^ +Physical.+: (.+)$/) { $P = $1; }')

	# echo "$IP_INFO"

	# echo

	netstat -rn | perl -nle 'print "$1 = $2 = $5" if /^( {1,2}[0-9]{1,2})\.{3}(([[:xdigit:]]{2} ){5}([[:xdigit:]]{2})) \.+(.+)$/' | sort -k1,3 | perl -nle 'print $1 if /^.{6}([0-9a-fA-F ]{17})/' | tr [a-f\ ] [A-F-] | while read -r line; do
		echo "$IP_INFO" | grep $line
		# echo $IP_INFO | grep $line
	done
else
	echo "This script currently supports Cygwin only."
fi
