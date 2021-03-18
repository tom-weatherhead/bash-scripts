#!/bin/bash

# - From https://ffmpeg.org/ffmpeg-bitstream-filters.html#mpeg4_005funpack_005fbframes :

# 2.13 mpeg4_unpack_bframes

# Unpack DivX-style packed B-frames.

# DivX-style packed B-frames are not valid MPEG-4 and were only a workaround for the broken Video for Windows subsystem. They use more space, can cause minor AV sync issues, require more CPU power to decode (unless the player has some decoded picture queue to compensate the 2,0,2,0 frame per packet style) and cause trouble if copied into a standard container like mp4 or mpeg-ps/ts, because MPEG-4 decoders may not be able to decode them, since they are not valid MPEG-4.

# For example to fix an AVI file containing an MPEG-4 stream with DivX-style packed B-frames using ffmpeg, you can use the command:

# ffmpeg -i INPUT.avi -codec copy -bsf:v mpeg4_unpack_bframes OUTPUT.avi

. bash_script_include.sh

which_test ffmpeg

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly one file to convert must be specified as a command-line argument."
fi

# In order to handle spaces in $1, wrap it in quotes: "$1"

INPUT_FILENAME="$1"

# Get file extension: see http://tecadmin.net/how-to-extract-filename-extension-in-shell-script/
INPUT_FILENAME_WITH_EXTENSION=$(basename "$INPUT_FILENAME")
INPUT_EXTENSION="${INPUT_FILENAME_WITH_EXTENSION##*.}" # If INPUT_FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of INPUT_FILENAME_WITH_EXTENSION

# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
BASE_FILENAME=$(basename -s ."$INPUT_EXTENSION" "$INPUT_FILENAME")
OUTPUT_FILENAME="$BASE_FILENAME.bframes_unpacked.$INPUT_EXTENSION"

START_TIME=$(date -u +'%F at %H:%M:%S')

# echo $(printf "ffmpeg -i %q -codec copy -bsf:v mpeg4_unpack_bframes -threads 1 %q" "$INPUT_FILENAME" "$OUTPUT_FILENAME")
echo_and_eval $(printf "ffmpeg -i %q -codec copy -bsf:v mpeg4_unpack_bframes -threads 1 %q" "$INPUT_FILENAME" "$OUTPUT_FILENAME")

EXIT_STATUS=$?

FINISH_TIME=$(date -u +'%F at %H:%M:%S')

echo "Started at:  $START_TIME"
echo "Finished at: $FINISH_TIME"

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "ffmpeg experienced an error."
fi

clean_up $EXIT_STATUS
