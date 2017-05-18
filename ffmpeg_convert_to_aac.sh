#!/bin/bash

# Convert the audio track of an .mp4 file to an .m4a AAC file via ffmpeg - As a *nix shell script - May 16, 2017

# See https://trac.ffmpeg.org/wiki/Encode/AAC

. bash_script_include.sh

PROGRAM_NAME=$(basename "$0")

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME [-c | -v] InputMP4Filename"
	echo_error_message "-c : Constant Bitrate Encoding (CBR) (default)"
	echo_error_message "-v : Variable Bitrate Encoding (VBR)"
	echo_error_message "-t n : Adjust the audio tempo: Speed up the audio by a factor of n"
	echo_error_message
}

which_test ffmpeg

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly one file to convert must be specified as a command-line argument."
fi

# In order to handle spaces in $1, wrap it in quotes: "$1"
# See https://unix.stackexchange.com/questions/151807/how-to-pass-argument-with-spaces-to-a-shell-script-function
# See also https://www.google.ca/search?q=bash+script+parameter+with+spaces

# Get file extension: see http://tecadmin.net/how-to-extract-filename-extension-in-shell-script/
FILENAME_WITH_EXTENSION=$(basename "$1")
EXTENSION="${FILENAME_WITH_EXTENSION##*.}" # If FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of FILENAME_WITH_EXTENSION

# if [ "${EXTENSION,,}" != mp4 ]; then  # Do a case-insensitive string comparison by converting the variable argument to lower-case before the comparison. Specific to bash (version 4.0+ ?)
if [ "$(echo $EXTENSION | tr '[A-Z]' '[a-z]')" != mp4 ]; then	# Do a case-insensitive string comparison by converting the variable argument to lower-case before the comparison. This works on bash and dash.
	usage
	error_exit "\"$1\" is not an .mp4 file; its extension is .$EXTENSION"
fi

# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
FILENAME=$(basename -s ."$EXTENSION" "$1")

SOURCE_FILE_PATH="$1"
SOURCE_FILENAME_WITH_EXTENSION=$(basename "$SOURCE_FILE_PATH")
SOURCE_EXTENSION="${SOURCE_FILENAME_WITH_EXTENSION##*.}" # If SOURCE_FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of SOURCE_FILENAME_WITH_EXTENSION

# Is this SOURCE_FILENAME_BASE or is it all of SOURCE_FILE_PATH minus the extension? -> The former: Just the filename base. E.g. If SOURCE_FILE_PATH is /dir1/dir2/dir3/filename.ext, then SOURCE_FILENAME_BASE is just "filename".
SOURCE_FILENAME_BASE=$(basename -s ."$SOURCE_EXTENSION" "$SOURCE_FILE_PATH")

DEST_FILENAME_WITH_EXTENSION="$SOURCE_FILENAME_BASE.m4a"

echo "SOURCE_FILE_PATH is $SOURCE_FILE_PATH"
echo "SOURCE_FILENAME_WITH_EXTENSION is $SOURCE_FILENAME_WITH_EXTENSION"
echo "SOURCE_EXTENSION is $SOURCE_EXTENSION"
echo "SOURCE_FILENAME_BASE is $SOURCE_FILENAME_BASE"
echo "DEST_FILENAME_WITH_EXTENSION is $DEST_FILENAME_WITH_EXTENSION"

# [[ $SOURCE_STRING =~ Key:\ (.*)$ ]] && echo "Bash regex match: ${BASH_REMATCH[1]}"

# [[ $(ffmpeg -i Kollaps\ -\ Full\ Album.mp4 2>&1) =~ Audio:\ abc ]] && echo "Yes!" || echo "Nope."

# ffmpeg -i "$1" -vn -acodec libmp3lame -ac 2 -ab 160k -ar 48000 "$FILENAME.mp3" || error_exit "ffmpeg returned an error: $?" # I believe that $? will contain the error code that ffmpeg returned.

# We want only audio in the output. So:
# -vn : Don't copy or transcode the source video stream.
# -sn : Don't copy or transcode the source subtitle stream.

FFMPEG_INFO_OUTPUT=$(ffmpeg -i "$1" 2>&1)

[[ "$FFMPEG_INFO_OUTPUT" =~ Audio:\ aac ]] && {
	# The source audio stream is already encoded as AAC; just copy it.
	echo "The source audio stream is encoded as AAC; copying..."
	CODEC="copy"

	# ? Should we redirect stderr to stdout here with 2>&1, or should we not? Might the process invoking this script want to distinguish between stdout and stderr?
	echo_and_eval $(printf "ffmpeg -i %q -vn -sn -c:a $CODEC %q 2>&1" "$SOURCE_FILE_PATH" "$DEST_FILENAME_WITH_EXTENSION")
} || {
	# The source audio stream is not encoded as AAC; Use the libfdk_aac codec to encode it as AAC.
	echo "The source audio stream is not encoded as AAC; transcoding to AAC..."

	[[ "$FFMPEG_INFO_OUTPUT" =~ libfdk_aac ]] && {
		# The libfdk_aac codec is availale.
		CODEC="libfdk_aac"
	} || {
		CODEC="aac"
	}

	echo "Using the $CODEC codec to transcode the audio stream to AAC..."
	KBPS_OUT="128"
	echo_and_eval $(printf "ffmpeg -i %q -vn -sn -c:a $CODEC -b:a ${KBPS_OUT}k %q 2>&1" "$SOURCE_FILE_PATH" "$DEST_FILENAME_WITH_EXTENSION")
}

EXIT_STATUS=$?

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "ffmpeg experienced an error."
	# Call get_ffmpeg_error_message($EXIT_STATUS) in bash_script_include ?
fi

clean_up $EXIT_STATUS
