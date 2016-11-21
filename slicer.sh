#!/bin/bash

# Slicer - Cut up a file into slices that can later be reassembled into a copy of the original file - September 24, 2016

# The resulting slices can be reassembled via:
# - *nix / Cygwin:      cat Slice*.bin > outputfile
#   - cat doesn't distinguish between binary data and text data.
# - Windows cmd:        copy Slice*.bin /B outputfile /B
#   - I don't see a way to do this using xcopy instead of copy.
# - Windows PowerShell: Get-Content -Encoding Byte .\Slice*.bin | Set-Content -Encoding Byte outputfile

# The correctness of the slicing and reconstruction can be verified by md5sum or sha*sum (sha1sum, sha512sum, etc.); e.g.:
# - sha512sum inputfile && sha512sum outputfile
# - sha512sum *.pdf

# Praise the LORD for dd. (And for stat, even though it is non-standard Linux/*nix extension. See http://unix.stackexchange.com/questions/16640/how-can-i-get-the-size-of-a-file-in-a-bash-script .)

PROGRAM_NAME=$(basename "$0")

usage()
{
	# Output the usage message to the standard error stream.
	echo 1>&2
	echo "Usage: $PROGRAM_NAME inputfile [maximum number of 4 KB blocks per slice; default = 1048575]" 1>&2
	echo 1>&2
	echo "By default, each slice will be at most 4 GB minus 4 KB; ideal for 32-bit file systems." 1>&2
	echo 1>&2
	echo "Examples:" 1>&2
	echo "  $PROGRAM_NAME Document.pdf 128" 1>&2
	echo "  $PROGRAM_NAME BigDisk.iso" 1>&2
	echo 1>&2
}

clean_up()
{
	# Perform end-of-execution housekeeping
	# Optionally accepts an exit status
	exit $1
}

error_exit()
{
	# Display an error message and exit
	echo "${PROGRAM_NAME}: ${1:-"Unknown Error"}" 1>&2
	clean_up 1
}

trap clean_up SIGHUP SIGINT SIGTERM

# A maximum of 1048575 blocks per slice allows each slice to be as large as 4 GB - 4 KB, suitable for slicing a file into slices that can be stored on 32-bit file systems (e.g. FAT32), such as on many USB Flash drives.
BLOCK_SIZE=4096 # Bytes
NUM_BLOCKS_PER_SLICE_TO_FIT_WITHIN_4GB=1048575
DEFAULT_NUM_BLOCKS_PER_SLICE=$NUM_BLOCKS_PER_SLICE_TO_FIT_WITHIN_4GB

# 2016/09/26 : Used a case structure, switching on the value of $# ; see the example at http://linuxcommand.org/lc3_wss0110.php

# Without case: if [ $# -lt 1 ]; then ... elif [ $# -lt 2 ]; then ... else ... fi

case $# in
	1 )	NUM_BLOCKS_PER_SLICE=$DEFAULT_NUM_BLOCKS_PER_SLICE
		echo "Using the default NUM_BLOCKS_PER_SLICE=$NUM_BLOCKS_PER_SLICE"
		;;
	2 ) NUM_BLOCKS_PER_SLICE=$2
		echo "Using NUM_BLOCKS_PER_SLICE=$NUM_BLOCKS_PER_SLICE"
		;;
	* )	usage
		error_exit "Incorrect number of arguments"
esac

if [ $NUM_BLOCKS_PER_SLICE -eq $NUM_BLOCKS_PER_SLICE_TO_FIT_WITHIN_4GB ]; then
	echo "Each slice will be at most 4 GB minus 4 KB; ideal for 32-bit file systems."
fi

# LS_OUTPUT=$(ls -ln "$1")
# SSS=${LS_OUTPUT[4]}
# echo "SSS = $SSS"

# DU_OUTPUT=$(du -b "$1")
# DDD=${DU_OUTPUT[4]}
# echo "DDD = $DDD"

# TODO: 2016/11/20 : A bug to fix: if $1 is a symbolic link, stat will find the size of the link itself,
# not the size of the file to which the link refers.
FILESIZE=$(stat -c%s "$1")
echo "FILESIZE = $FILESIZE"
echo "BLOCK_SIZE = $BLOCK_SIZE"
NUM_BLOCKS_REMAINING=$(((FILESIZE + BLOCK_SIZE - 1) / BLOCK_SIZE))
SKIP=0
i=0

echo "NUM_BLOCKS_REMAINING = $NUM_BLOCKS_REMAINING"
echo "NUM_BLOCKS_PER_SLICE = $NUM_BLOCKS_PER_SLICE"

# while [ "$NUM_BLOCKS_REMAINING" -gt "$NUM_BLOCKS_PER_SLICE" ]; do		# Comparing strings?
while [ $NUM_BLOCKS_REMAINING -gt $NUM_BLOCKS_PER_SLICE ]; do			# Comparing integers
	echo "dd if=$1 of=Slice$i.bin iflag=fullblock bs=$BLOCK_SIZE skip=$SKIP count=$NUM_BLOCKS_PER_SLICE"
	dd if="$1" of=Slice$i.bin iflag=fullblock bs=$BLOCK_SIZE skip=$SKIP count=$NUM_BLOCKS_PER_SLICE
	NUM_BLOCKS_REMAINING=$((NUM_BLOCKS_REMAINING - NUM_BLOCKS_PER_SLICE))
	SKIP=$((SKIP + NUM_BLOCKS_PER_SLICE))
    i=$((i + 1))

	echo "NUM_BLOCKS_REMAINING = $NUM_BLOCKS_REMAINING"
	echo "NUM_BLOCKS_PER_SLICE = $NUM_BLOCKS_PER_SLICE"
done

echo "dd if=$1 of=Slice$i.bin iflag=fullblock bs=$BLOCK_SIZE skip=$SKIP"
dd if="$1" of=Slice$i.bin iflag=fullblock bs=$BLOCK_SIZE skip=$SKIP
echo "Done."
clean_up