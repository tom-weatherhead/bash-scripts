#!/bin/bash

# Convert media files to .mp4 via ffmpeg - As a *nix shell script - November 27, 2016

# See https://trac.ffmpeg.org/wiki/Encode/H.264

# Ubuntu ffmpeg installation instructions:
# The libmp3lame codec is included in the apt package libavcodec-extra-53, which is included in the apt package ubuntu-restricted-extras .
# So, to install ffmpeg and the libmp3lame codec, do this:
# $ sudo apt-get install ffmpeg ubuntu-restricted-extras (also: x264 ?)

# 64-bit Windows ffmpeg installation instructions:
# 1) Download the latest (stable) version of ffmpeg as a .zip file from https://ffmpeg.zeranoe.com/builds/win64/static/
# 2) Unzip it.
# 3) Rename the inner directory (the one that contains bin, doc, licenses, and presets) as ffmpeg
# 4) Move the ffmpeg directory to "C:\Program Files"
# 5) Ensure that "C:\Program Files\ffmpeg\bin" is in the system PATH
# In your *nix-on-Windows command shell:
#   - Create the directory ~/bin if it does not yet exist
#   - Ensure that ~/bin is in the PATH: See ~/.profile and ~/.bash_profile
#   - cd ~/bin
#   - ln -sf "/.../c/Program Files/ffmpeg/bin/ffmpeg.exe" (or: /.../c/Program\ Files/ffmpeg/bin/ffmpeg.exe)
#   - ln -s ffmpeg.exe ffmpeg
#   - ln -sf /path/to/ffmpeg_convert_to_mp4.sh
#   - ln -s ffmpeg_convert_to_mp4.sh ffmpeg_convert_to_mp4
# Note: As of November 27, 2016, the Windows version of ffmpeg cannot be invoked from Window 10 Bash in the current production version of Windows (build 14.393.447), but it can in the current Insider Preview build (14971).

# CRF (constant rate factor) Example:
#
# ffmpeg -i input -c:v libx264 -preset slow -crf 22 -c:a copy output.mkv
#
# Note that in this example the audio stream of the input file is simply ​stream copied over to the output and not re-encoded. 

# Two-Pass
#
# This method is generally used if you are targeting a specific output file size and output quality from frame to frame is of less importance. This is best explained with an example. Your video is 10 minutes (600 seconds) long and an output of 50 MB is desired. Since bitrate = file size / duration:
#
# (50 MB * 8192 [converts MB to kilobits]) / 600 seconds = ~683 kilobits/s total bitrate
# 683k - 128k (desired audio bitrate) = 555k video bitrate
#
# Two-Pass Example
#
# ffmpeg -y -i input -c:v libx264 -preset medium -b:v 555k -pass 1 -c:a libfdk_aac -b:a 128k -f mp4 /dev/null && \
# ffmpeg -i input -c:v libx264 -preset medium -b:v 555k -pass 2 -c:a libfdk_aac -b:a 128k output.mp4
#
# Note: Windows users should use NUL instead of /dev/null.
#
# As with CRF, choose the slowest preset you can tolerate.
#
# In pass 1 specify a output format with -f that matches the output format in pass 2. Also in pass 1, specify the audio codec used in pass 2; in many cases -an in pass 1 will not work.
#
# See ​Making a high quality MPEG-4 ("DivX") rip of a DVD movie : http://www.mplayerhq.hu/DOCS/HTML/en/menc-feat-dvd-mpeg4.html
# It is an MEncoder guide, but it will give you an insight about how important it is to use two-pass when you want to efficiently use every bit when you're constrained with storage space. 

# Lossless H.264
#
# You can use -crf 0 to encode a lossless output. Two useful presets for this are ultrafast or veryslow since either a fast encoding speed or best compression are usually the most important factors. Most non-FFmpeg based players will not be able to decode lossless (but YouTube can), so if compatibility is an issue you should not use lossless.
#
# Note that lossless output files will likely be huge.
# Lossless Example (fastest encoding)
#
# ffmpeg -i input -c:v libx264 -preset ultrafast -crf 0 output.mkv
#
# Lossless Example (best compression)
#
# ffmpeg -i input -c:v libx264 -preset veryslow -crf 0 output.mkv

PROGRAM_NAME=$(basename "$0")

usage()
{
	# Output the usage message to the standard error stream.
	echo
	echo "Usage: $PROGRAM_NAME InputFilename" 1>&2
#	echo "Usage: $PROGRAM_NAME [-c | -v] InputFilename" 1>&2
#	echo "-c : Constant Bitrate Encoding (CBR) (default)" 1>&2
#	echo "-v : Variable Bitrate Encoding (VBR)" 1>&2
#	echo "-t n : Adjust the audio tempo: Speed up the audio by a factor of n" 1>&2
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

trap clean_up SIGHUP SIGINT SIGTERM

# Using getopts to detect and handle options such as -c and -v : See https://stackoverflow.com/questions/16483119/example-of-how-to-use-getopts-in-bash

CONSTANT_RATE_FACTOR=1 # Our default.
# AUDIO_TEMPO_FACTOR=0

#while getopts ":c:v:t:" option; do
#    case $option in
#        c)
#			# echo "-c detected"
#            ;;
#        v)
#            # If an option value followed the -v, it would be in $OPTARG or ${OPTARG}; e.g. if -vABC was passed in, $OPTARG would be ABC. There is no need to use = ; e.g. -v=ABC
#			# echo "-v detected $OPTARG ${OPTARG}"
#			CONSTANT_RATE_FACTOR=0
#            ;;
#        t)
#			AUDIO_TEMPO_FACTOR=$OPTARG
#			echo "AUDIO_TEMPO_FACTOR = $AUDIO_TEMPO_FACTOR"
#            ;;
#        *)
#            usage
#			error_exit "Unrecognized option: -$OPTARG"
#            # No ;; is necessary here.
#    esac
#	shift
#done

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly one file to convert must be specified as a command-line argument."
fi

# In order to handle spaces in $1, wrap it in quotes: "$1"

# Get file extension: see http://tecadmin.net/how-to-extract-filename-extension-in-shell-script/
FILENAME_WITH_EXTENSION=$(basename "$1")
EXTENSION="${FILENAME_WITH_EXTENSION##*.}" # If FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of FILENAME_WITH_EXTENSION

# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
FILENAME=$(basename -s ."$EXTENSION" "$1")

if [ $CONSTANT_RATE_FACTOR != 0 ]; then
	echo "Constant Rate Factor (CRF)"
#	BITRATE_SETTING="-ab 160k"
else
	echo "Something other than Constant Rate Factor (CRF)"
#	echo "Variable Bitrate Encoding (VBR)"
#	echo "Using settings with a target bitrate of 165 Kbits/s and a bitrate range of 140...185"
#	BITRATE_SETTING="-qscale:a 4"
fi

# bash cannot handle floating-point numbers, so invoke bc to do the floating-point comparisons.
# See https://stackoverflow.com/questions/15224581/floating-point-comparison-with-variable-in-bash
#if (( $(bc <<< "$AUDIO_TEMPO_FACTOR >= 0.5") && $(bc <<< "$AUDIO_TEMPO_FACTOR <= 2.0"))); then
#	echo "The audio tempo will be adjusted by a factor of $AUDIO_TEMPO_FACTOR"
#	echo "ffmpeg -i \"$1\" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -filter:a \"atempo=$AUDIO_TEMPO_FACTOR\" -ar 48000 \"$FILENAME.mp3\""
#	ffmpeg -i "$1" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -filter:a "atempo=$AUDIO_TEMPO_FACTOR" -ar 48000 "$FILENAME.mp3" || error_exit "ffmpeg returned an error: $?" # I believe that $? will contain the error code that ffmpeg returned.
#else
#	echo "No valid AUDIO_TEMPO_FACTOR detected - the audio tempo will not be changed."
#	echo "ffmpeg -i \"$1\" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -ar 48000 \"$FILENAME.mp3\""
#	ffmpeg -i "$1" -vn -acodec libmp3lame -ac 2 $BITRATE_SETTING -ar 48000 "$FILENAME.mp3" || error_exit "ffmpeg returned an error: $?" # I believe that $? will contain the error code that ffmpeg returned.
#fi

ffmpeg -i "$1" -c:v libx264 -preset slow -crf 22 -c:a copy "$FILENAME.mp4" || error_exit "ffmpeg returned an error: $?"

# clean_up # Let ffmpeg be the last command in the script, so that ffmpeg's exit code will be the exit code of the script.