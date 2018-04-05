#!/bin/bash

# ffmpeg_copy_video_only.sh

# See https://superuser.com/questions/441361/strip-metadata-from-all-formats-with-ffmpeg

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME InputFilename"
	echo_error_message
}

which_test ffmpeg

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly one file must be specified as a command-line argument."
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

# DEST_FILENAME_WITH_EXTENSION="$SOURCE_FILENAME_BASE.$AUDIO_CODEC_IN_DEST_FILENAME.m4a"	# Annoying.
DEST_FILENAME_WITH_EXTENSION="$SOURCE_FILENAME_BASE.VideoOnly.$SOURCE_EXTENSION"

echo "DEST_FILENAME_WITH_EXTENSION is $DEST_FILENAME_WITH_EXTENSION"

# We want only audio in the output. So:
# -vn : Don't copy or transcode the source video stream.
# -sn : Don't copy or transcode the source subtitle stream.

# ? Should we redirect stderr to stdout here with 2>&1, or should we not? Might the process invoking this script want to distinguish between stdout and stderr?
# echo $(printf "ffmpeg -i %q -vn -sn -c:a $AUDIO_CODEC %q 2>&1" "$SOURCE_FILE_PATH" "$DEST_FILENAME_WITH_EXTENSION")
echo_and_eval $(printf "ffmpeg -i %q -map_metadata -1 -c:v copy -an -dn -sn %q 2>&1" "$SOURCE_FILE_PATH" "$DEST_FILENAME_WITH_EXTENSION")

EXIT_STATUS=$?

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "ffmpeg experienced an error."
	# Call get_ffmpeg_error_message($EXIT_STATUS) in bash_script_include ?
fi

clean_up $EXIT_STATUS

# ffmpeg -i input.mp4 -map_metadata -1 -c:v copy -an output.mp4
# ffmpeg -i input.mp4 -map_metadata -1 -c:v copy -an -dn -sn output.mp4
