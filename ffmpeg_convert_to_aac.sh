#!/bin/bash

# Convert the audio track of an .mp4 file to an .m4a AAC file via ffmpeg - As a *nix shell script - May 16, 2017

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

# Using getopts to detect and handle options such as -c and -v : See https://stackoverflow.com/questions/16483119/example-of-how-to-use-getopts-in-bash

CONSTANT_BITRATE=1 # Our default.
AUDIO_TEMPO_FACTOR_SET=0 # Use this variable so that "bc" does not need to be present unless the user wishes to change the audio tempo.
AUDIO_TEMPO_FACTOR=0

while getopts ":c:v:t:" option; do
    case $option in
        c)
			# echo "-c detected"
            ;;
        v)
            # If an option value followed the -v, it would be in $OPTARG or ${OPTARG}; e.g. if -vABC was passed in, $OPTARG would be ABC. There is no need to use = ; e.g. -v=ABC
			# echo "-v detected $OPTARG ${OPTARG}"
			CONSTANT_BITRATE=0
            ;;
        t)
			AUDIO_TEMPO_FACTOR_SET=1
			AUDIO_TEMPO_FACTOR=$OPTARG
			echo "AUDIO_TEMPO_FACTOR = $AUDIO_TEMPO_FACTOR"
            ;;
        *)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
done

shift $((OPTIND -1))

#echo "\$* is $*" # I saw $* metioned in https://unix.stackexchange.com/questions/156223/bash-how-to-remove-options-from-parameters-after-processing

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

# if [ $CONSTANT_BITRATE != 0 ]; then
	# echo "Constant Bitrate Encoding (CBR)"
	# BITRATE_SETTING="-ab 160k"
# else
	# echo "Variable Bitrate Encoding (VBR)"
	# echo "Using settings with a target bitrate of 165 Kbits/s and a bitrate range of 140...185"
	# BITRATE_SETTING="-qscale:a 4"
# fi

# if [ $AUDIO_TEMPO_FACTOR_SET != 0 ]; then
	# bash cannot handle floating-point numbers, so invoke bc to do the floating-point comparisons.
	# See https://stackoverflow.com/questions/15224581/floating-point-comparison-with-variable-in-bash

	# which_test bc

	# if (( $(bc <<< "$AUDIO_TEMPO_FACTOR < 0.5") || $(bc <<< "$AUDIO_TEMPO_FACTOR > 2.0"))); then
		# error_exit "The audio tempo factor is not in the range [0.5, 2.0]; exiting."
	# fi

	# echo "The audio tempo will be adjusted by a factor of $AUDIO_TEMPO_FACTOR"
	# echo "ffmpeg -i \"$1\" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -filter:a \"atempo=$AUDIO_TEMPO_FACTOR\" -ar 48000 \"$FILENAME.mp3\""
	# ffmpeg -i "$1" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -filter:a "atempo=$AUDIO_TEMPO_FACTOR" -ar 48000 "$FILENAME.mp3" || error_exit "ffmpeg returned an error: $?" # I believe that $? will contain the error code that ffmpeg returned.
# else
	# echo "No valid AUDIO_TEMPO_FACTOR detected - the audio tempo will not be changed."
	# echo "ffmpeg -i \"$1\" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -ar 48000 \"$FILENAME.mp3\""
	# ffmpeg -i "$1" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -ar 48000 "$FILENAME.mp3" || error_exit "ffmpeg returned an error: $?" # I believe that $? will contain the error code that ffmpeg returned.
# fi

# [[ $SOURCE_STRING =~ Key:\ (.*)$ ]] && echo "Bash regex match: ${BASH_REMATCH[1]}"

# [[ $(ffmpeg -i Kollaps\ -\ Full\ Album.mp4 2>&1) =~ Audio:\ abc ]] && echo "Yes!" || echo "Nope."

# ffmpeg -i "$1" -vn -acodec libmp3lame -ac 2 -ab 160k -ar 48000 "$FILENAME.mp3" || error_exit "ffmpeg returned an error: $?" # I believe that $? will contain the error code that ffmpeg returned.

# We want only audio in the output. So:
# -vn : Don't copy or transcode the source video stream.
# -sn : Don't copy or transcode the source subtitle stream.

[[ $(ffmpeg -i "$1") =~ Audio:\ aac ]] && {
	# The source audio stream is already encoded as AAC; just copy it.
	CODEC="copy"

	echo_and_eval $(printf "ffmpeg -i %q -vn -sn -a:c $CODEC %q" "%1" "$FILENAME.m4a")
} || {
	# The source audio stream is not encoded as AAC; Use the libfdk_aac codec to encode it as AAC.

	[[ $(ffmpeg -i 2>&1) =~ libfdk_aac ]] && {
		# The libfdk_aac codec is availale.
		CODEC="libfdk_aac"
	} || {
		CODEC="aac"
	}

	echo_and_eval $(printf "ffmpeg -i %q -vn -sn -a:c $CODEC -b:a 128k %q" "%1" "$FILENAME.m4a")
}

EXIT_STATUS=$?

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "ffmpeg experienced an error."
	# Call get_ffmpeg_error_message($EXIT_STATUS) in bash_script_include ?
fi

clean_up $EXIT_STATUS
