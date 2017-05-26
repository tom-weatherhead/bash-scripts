#!/bin/bash

# Convert the audio track of an .mp4 file to an .m4a AAC file via ffmpeg - As a *nix shell script - May 16, 2017

# See https://trac.ffmpeg.org/wiki/Encode/AAC

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME [-b { 64 | 96 | 128 | 192 | 256 }] InputFilename"
	echo_error_message "  -b : Sets the output audio bitrate (in kilobits per second)"
	echo_error_message
}

which_test ffmpeg

AUDIO_KBPS_OUT="128"

while getopts "b:" option; do
    case $option in
		b) # Set the output audio bitrate (in kilobits per second)
			[ $(is_a_non_negative_integer $OPTARG) ] && {
				if [ $OPTARG -eq 64 ] || [ $OPTARG -eq 96 ] || [ $OPTARG -eq 128 ] || [ $OPTARG -eq 192 ] || [ $OPTARG -eq 256 ]; then
					AUDIO_KBPS_OUT=$OPTARG
				else
					usage
					error_exit "Option -b : The argument '$OPTARG' is not one of 64, 96, 128, 192, or 256"
				fi
			} || {
				usage
				error_exit "Option -b : The argument '$OPTARG' is not a non-negative integer"
			}
			;;
        *)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
done

shift $((OPTIND -1))

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

# FFMPEG_INFO_OUTPUT=
FFMPEG_INFO_OUTPUT=$(ffmpeg -i "$SOURCE_FILE_PATH" 2>&1)
# Should we do this? : FFMPEG_INFO_OUTPUT=$(ffmpeg -i "$SOURCE_FILE_PATH" 2>&1 -c copy /dev/null)

echo "$FFMPEG_INFO_OUTPUT" | grep -q Audio:\ aac && {
	# The source audio stream is already encoded as AAC; just copy it.
	echo "The source audio stream is encoded as AAC; copying..."
	AUDIO_CODEC="copy"
	AUDIO_CODEC_IN_DEST_FILENAME="aac.$AUDIO_CODEC"
} || {
	# The source audio stream is not encoded as AAC; Use the libfdk_aac codec to encode it as AAC.
	echo "The source audio stream is not encoded as AAC; transcoding to AAC..."

	echo "$FFMPEG_INFO_OUTPUT" | grep -q libfdk_aac && {
		# The libfdk_aac codec is available.
		echo "libfdk_aac detected. Yay!"
		AUDIO_CODEC="libfdk_aac"
	} || {
		AUDIO_CODEC="aac"
	}

	echo "Using the $CODEC codec to transcode the audio stream to AAC..."
	AUDIO_CODEC_IN_DEST_FILENAME="$AUDIO_CODEC.${AUDIO_KBPS_OUT}kbps"
	AUDIO_CODEC="$AUDIO_CODEC -b:a ${AUDIO_KBPS_OUT}k"
}

DEST_FILENAME_WITH_EXTENSION="$SOURCE_FILENAME_BASE.$AUDIO_CODEC_IN_DEST_FILENAME.m4a"

echo "DEST_FILENAME_WITH_EXTENSION is $DEST_FILENAME_WITH_EXTENSION"

# We want only audio in the output. So:
# -vn : Don't copy or transcode the source video stream.
# -sn : Don't copy or transcode the source subtitle stream.

# ? Should we redirect stderr to stdout here with 2>&1, or should we not? Might the process invoking this script want to distinguish between stdout and stderr?
# echo $(printf "ffmpeg -i %q -vn -sn -c:a $AUDIO_CODEC %q 2>&1" "$SOURCE_FILE_PATH" "$DEST_FILENAME_WITH_EXTENSION")
echo_and_eval $(printf "ffmpeg -i %q -vn -sn -c:a $AUDIO_CODEC %q 2>&1" "$SOURCE_FILE_PATH" "$DEST_FILENAME_WITH_EXTENSION")

EXIT_STATUS=$?

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "ffmpeg experienced an error."
	# Call get_ffmpeg_error_message($EXIT_STATUS) in bash_script_include ?
fi

clean_up $EXIT_STATUS

# ***

# ffmpeg -i 2>&1 | grep -q ffmpeg && echo "Yay!" || echo "Non."
# ffmpeg -i 2>&1 | grep -q 264 && echo "Yay!" || echo "Non."
# ffmpeg -i 2>&1 | grep -q 265 && echo "Yay!" || echo "Non."
