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

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME inputfile [maximum number of 4 KB blocks per slice; default = 1048575]"
	echo_error_message
	echo_error_message "By default, each slice will be at most 4 GB minus 4 KB; ideal for 32-bit file systems."
	echo_error_message
	echo_error_message "Examples:"
	echo_error_message "  $PROGRAM_NAME Document.pdf 128"
	echo_error_message "  $PROGRAM_NAME BigDisk.iso"
	echo_error_message
}

which_test awk
which_test dd

BLOCK_SIZE=4096 # Bytes
NUM_BLOCKS_PER_SLICE_TO_FIT_WITHIN_4GB=1048575
DEFAULT_NUM_BLOCKS_PER_SLICE=$NUM_BLOCKS_PER_SLICE_TO_FIT_WITHIN_4GB

# 2016/09/26 : Used a case structure, switching on the value of $# ; see the example at http://linuxcommand.org/lc3_wss0110.php

# Without case: if [ $# -lt 1 ]; then ... elif [ $# -lt 2 ]; then ... else ... fi

case $# in
	1)	NUM_BLOCKS_PER_SLICE=$DEFAULT_NUM_BLOCKS_PER_SLICE
		echo "Using the default NUM_BLOCKS_PER_SLICE=$NUM_BLOCKS_PER_SLICE"
		;;
	2) NUM_BLOCKS_PER_SLICE=$2
		echo "Using NUM_BLOCKS_PER_SLICE=$NUM_BLOCKS_PER_SLICE"
		;;
	*)	usage
		error_exit "Incorrect number of arguments"
esac

if [ $NUM_BLOCKS_PER_SLICE -eq $NUM_BLOCKS_PER_SLICE_TO_FIT_WITHIN_4GB ]; then
	echo "Each slice will be at most 4 GB minus 4 KB; ideal for 32-bit file systems."
fi

# TODO: Ensure that this ls-awk solution is portable.
FILESIZE=$(ls -lH "$1" | awk '{print $5}')
NUM_BLOCKS_REMAINING=$(((FILESIZE + BLOCK_SIZE - 1) / BLOCK_SIZE))
SKIP=0
i=0

# while [ "$NUM_BLOCKS_REMAINING" -gt "$NUM_BLOCKS_PER_SLICE" ]; do		# Comparing strings?
while [ $NUM_BLOCKS_REMAINING -gt $NUM_BLOCKS_PER_SLICE ]; do			# Comparing integers
	echo "dd if=$1 of=Slice$i.bin iflag=fullblock bs=$BLOCK_SIZE skip=$SKIP count=$NUM_BLOCKS_PER_SLICE"
	dd if="$1" of=Slice$i.bin iflag=fullblock bs=$BLOCK_SIZE skip=$SKIP count=$NUM_BLOCKS_PER_SLICE
	NUM_BLOCKS_REMAINING=$((NUM_BLOCKS_REMAINING - NUM_BLOCKS_PER_SLICE))
	SKIP=$((SKIP + NUM_BLOCKS_PER_SLICE))
    i=$((i + 1))
done

echo "dd if=$1 of=Slice$i.bin iflag=fullblock bs=$BLOCK_SIZE skip=$SKIP"
dd if="$1" of=Slice$i.bin iflag=fullblock bs=$BLOCK_SIZE skip=$SKIP
echo "Done."
clean_up