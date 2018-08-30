#!/bin/sh

# files_not_in.sh

# $1 : The path to the text file containing a list of md5 checksums
# $2 : The directory to search; defaults to .

MD5SUMFILE="$1"

if [ -z "$MD5SUMFILE" ]; then
	MD5SUMFILE="../md5*.txt"
fi

if ! [ -f "$MD5SUMFILE" ]; then
	echo "Error: $MD5SUMFILE is not a file."
	exit 1
fi

DIR="$2"

if [ -z "$DIR" ]; then
	DIR="."
fi

if ! [ -d "$DIR" ]; then
	echo "Error: $DIR is not a directory."
	exit 1
fi

find "$DIR" -type f -exec md5sum {} \; | while read line
do
	FOO=`echo $line | cut -c 1-32 -`
	grep -q "$FOO" $MD5SUMFILE || echo $line
done
