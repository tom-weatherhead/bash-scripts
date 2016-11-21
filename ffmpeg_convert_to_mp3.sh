#!/bin/bash

# Convert .mp4 files to .mp3 via ffmpeg - As a *nix shell script - October 12, 2016

# https://askubuntu.com/questions/84584/converting-mp4-to-mp3

# We use bash instead of sh because:
# a) On Ubuntu, sh defaults to dash;
# b) dash explodes on the expression "${EXTENSION,,}" ; it complains about a Bad Substitution.
# See https://stackoverflow.com/questions/20615217/bash-bad-substitution
# *nix shells include bash, zsh, ksh, tcsh, and dash.

# Further ideas about conversion to lower-case: See https://stackoverflow.com/questions/2264428/converting-string-to-lower-case-in-bash-shell-scripting :
# 1) $ echo "$a" | tr '[:upper:]' '[:lower:]'
#   - Note that only the tr and awk examples are specified in the POSIX standard. – Richard Hansen Feb 3 '12 at 18:55
#   - tr '[:upper:]' '[:lower:]' will use the current locale to determine uppercase/lowercase equivalents, so it'll work with locales that use letters with diacritical marks. – Richard Hansen Feb 3 '12 at 18:58
#   - How does one get the output into a new variable? Ie say I want the lowercased string into a new variable? – Adam Parkin Sep 25 '12 at 18:01
#     - @Adam: b="$(echo $a | tr '[A-Z]' '[a-z]')" – Tino Nov 14 '12 at 15:39 
# 2) a="$(tr [A-Z] [a-z] <<< "$a")"
# 3) In zsh: $a:l

# Ubuntu ffmpeg installation instructions:
# The libmp3lame codec is included in the apt package libavcodec-extra-53, which is included in the apt package ubuntu-restricted-extras .
# So, to install ffmpeg and the libmp3lame codec, do this:
# $ sudo apt-get install ffmpeg ubuntu-restricted-extras

# To change the speed of the audio: E.g. To speed up the audio by 1.25 x : Add: -filter:a "atempo=1.25"
# ffmpeg -i file.mp4 -filter:a "atempo=1.25" -vn -acodec libmp3lame -ac 2 -ab 160k -ar 48000 file.mp3
# - See https://trac.ffmpeg.org/wiki/How%20to%20speed%20up%20/%20slow%20down%20a%20video

# Functions stolen and adapted from printfile.sh : http://linuxcommand.org/lc3_wss0150.php

PROGRAM_NAME=$(basename "$0")

usage()
{
	# Output the usage message to the standard error stream.
	echo
	echo "Usage: $PROGRAM_NAME [-c | -v] InputMP4Filename" 1>&2
	echo "-c : Constant Bitrate Encoding (CBR) (default)" 1>&2
	echo "-v : Variable Bitrate Encoding (VBR)" 1>&2
	echo "-t n : Adjust the audio tempo: Speed up the audio by a factor of n" 1>&2
	echo
}

clean_up()
{
	# Perform end-of-execution housekeeping
	# Optionally accepts an exit status
	# rm -f $TEMP_FILE
	exit $1
}

error_exit()
{
	# Display an error message and exit
	echo "${PROGRAM_NAME}: ${1:-"Unknown Error"}" 1>&2
	clean_up 1
}

# This trap command works on bash, but on Ubuntu 16.10, dash (via sh) complains: "trap: SIGHUP: bad trap" ; another reason to use #!/bin/bash instead of #!/bin/sh ?
# See e.g. https://lists.yoctoproject.org/pipermail/yocto/2013-April/013125.html
trap clean_up SIGHUP SIGINT SIGTERM

# Using getopts to detect and handle options such as -c and -v : See https://stackoverflow.com/questions/16483119/example-of-how-to-use-getopts-in-bash

CONSTANT_BITRATE=1 # Our default.
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
			AUDIO_TEMPO_FACTOR=$OPTARG
			echo "AUDIO_TEMPO_FACTOR = $AUDIO_TEMPO_FACTOR"
            ;;
        *)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
	shift
done

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

if [ $CONSTANT_BITRATE != 0 ]; then
	echo "Constant Bitrate Encoding (CBR)"
	BITRATE_SETTING="-ab 160k"
else
	echo "Variable Bitrate Encoding (VBR)"
	echo "Using settings with a target bitrate of 165 Kbits/s and a bitrate range of 140...185"
	BITRATE_SETTING="-qscale:a 4"
fi

# bash cannot handle floating-point numbers, so invoke bc to do the floating-point comparisons.
# See https://stackoverflow.com/questions/15224581/floating-point-comparison-with-variable-in-bash
if (( $(bc <<< "$AUDIO_TEMPO_FACTOR >= 0.5") && $(bc <<< "$AUDIO_TEMPO_FACTOR <= 2.0"))); then
	echo "The audio tempo will be adjusted by a factor of $AUDIO_TEMPO_FACTOR"
	echo "ffmpeg -i \"$1\" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -filter:a \"atempo=$AUDIO_TEMPO_FACTOR\" -ar 48000 \"$FILENAME.mp3\""
	ffmpeg -i "$1" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -filter:a "atempo=$AUDIO_TEMPO_FACTOR" -ar 48000 "$FILENAME.mp3" || error_exit "ffmpeg returned an error: $?" # I believe that $? will contain the error code that ffmpeg returned.
else
	echo "No valid AUDIO_TEMPO_FACTOR detected - the audio tempo will not be changed."
	echo "ffmpeg -i \"$1\" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -ar 48000 \"$FILENAME.mp3\""
	ffmpeg -i "$1" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -ar 48000 "$FILENAME.mp3" || error_exit "ffmpeg returned an error: $?" # I believe that $? will contain the error code that ffmpeg returned.
fi

# clean_up # Let ffmpeg be the last command in the script, so that ffmpeg's exit code will be the exit code of the script.