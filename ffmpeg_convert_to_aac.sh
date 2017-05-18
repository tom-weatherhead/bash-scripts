#!/bin/bash

# Convert the audio track of an .mp4 file to an .m4a AAC file via ffmpeg - As a *nix shell script - May 16, 2017

# See https://trac.ffmpeg.org/wiki/Encode/AAC

. bash_script_include.sh

PROGRAM_NAME=$(basename "$0")

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME [-c | -v] InputFilename"
	# echo_error_message "-c : Constant Bitrate Encoding (CBR) (default)"
	# echo_error_message "-v : Variable Bitrate Encoding (VBR)"
	# echo_error_message "-t n : Adjust the audio tempo: Speed up the audio by a factor of n"
	echo_error_message
}

which_test ffmpeg

# TODO? Support an option to select the output bit rate in kilobits per second; e.g. -b [128 | 192 | 256]

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly one file to convert must be specified as a command-line argument."
fi

# In order to handle spaces in $1, wrap it in quotes: "$1"
# See https://unix.stackexchange.com/questions/151807/how-to-pass-argument-with-spaces-to-a-shell-script-function
# See also https://www.google.ca/search?q=bash+script+parameter+with+spaces

SOURCE_FILE_PATH="$1"

# Get file extension: see http://tecadmin.net/how-to-extract-filename-extension-in-shell-script/
SOURCE_FILENAME_WITH_EXTENSION=$(basename "$SOURCE_FILE_PATH")

SOURCE_EXTENSION="${SOURCE_FILENAME_WITH_EXTENSION##*.}" # If SOURCE_FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of SOURCE_FILENAME_WITH_EXTENSION

# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
# Is this SOURCE_FILENAME_BASE or is it all of SOURCE_FILE_PATH minus the extension? -> The former: Just the filename base. E.g. If SOURCE_FILE_PATH is /dir1/dir2/dir3/filename.ext, then SOURCE_FILENAME_BASE is just "filename".
SOURCE_FILENAME_BASE=$(basename -s ."$SOURCE_EXTENSION" "$SOURCE_FILE_PATH")

# echo "SOURCE_FILE_PATH is $SOURCE_FILE_PATH"
# echo "SOURCE_FILENAME_WITH_EXTENSION is $SOURCE_FILENAME_WITH_EXTENSION"
# echo "SOURCE_EXTENSION is $SOURCE_EXTENSION"
# echo "SOURCE_FILENAME_BASE is $SOURCE_FILENAME_BASE"

FFMPEG_INFO_OUTPUT=$(ffmpeg -i "$SOURCE_FILE_PATH" 2>&1)

[[ "$FFMPEG_INFO_OUTPUT" =~ Audio:\ aac ]] && {
	# The source audio stream is already encoded as AAC; just copy it.
	echo "The source audio stream is encoded as AAC; copying..."
	CODEC="copy"
} || {
	# The source audio stream is not encoded as AAC; Use the libfdk_aac codec to encode it as AAC.
	echo "The source audio stream is not encoded as AAC; transcoding to AAC..."

	[[ "$FFMPEG_INFO_OUTPUT" =~ libfdk_aac ]] && {
		# The libfdk_aac codec is available.
		CODEC="libfdk_aac"
	} || {
		CODEC="aac"
	}

	echo "Using the $CODEC codec to transcode the audio stream to AAC..."
	KBPS_OUT="128"
	# KBPS_OUT="192"
	# KBPS_OUT="256"
	CODEC="$CODEC -b:a ${KBPS_OUT}k"
}

DEST_FILENAME_WITH_EXTENSION="$SOURCE_FILENAME_BASE.aac.${KBPS_OUT}kbps.m4a"

echo "DEST_FILENAME_WITH_EXTENSION is $DEST_FILENAME_WITH_EXTENSION"

# We want only audio in the output. So:
# -vn : Don't copy or transcode the source video stream.
# -sn : Don't copy or transcode the source subtitle stream.

# ? Should we redirect stderr to stdout here with 2>&1, or should we not? Might the process invoking this script want to distinguish between stdout and stderr?
echo_and_eval $(printf "ffmpeg -i %q -vn -sn -c:a $CODEC %q 2>&1" "$SOURCE_FILE_PATH" "$DEST_FILENAME_WITH_EXTENSION")

EXIT_STATUS=$?

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "ffmpeg experienced an error."
	# Call get_ffmpeg_error_message($EXIT_STATUS) in bash_script_include ?
fi

clean_up $EXIT_STATUS
