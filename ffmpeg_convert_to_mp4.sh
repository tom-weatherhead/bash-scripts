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
#   -> It was added in build 14951. See https://github.com/Microsoft/BashOnWindows/issues/333

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

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME [-c [crf] | -2] InputFilename"
	echo_error_message "-c : Constant Rate Factor (CRF) Encoding (default); 17 <= crf <= 27"
	echo_error_message "-2 : Two-Pass Encoding"
	echo_error_message
	echo_error_message "Examples:"
	echo_error_message "$PROGRAM_NAME InputFilename"
	echo_error_message "$PROGRAM_NAME -c -- InputFilename"
	echo_error_message "$PROGRAM_NAME -c 17 InputFilename"
	echo_error_message "$PROGRAM_NAME -2 InputFilename"
	echo_error_message
}

clean_up() # ? Will this definition of "clean_up" replace the one included from bash_script_include.sh ?
{
	# Perform end-of-execution housekeeping
	# Optionally accepts an exit status
	# TEMP_FILES="ffmpeg2pass-*.log*"
	# rm -f $TEMP_FILES
	rm -f ffmpeg2pass-*.log*
	exit $1
}

which_test ffmpeg

# Using getopts to detect and handle command-line options : See https://stackoverflow.com/questions/16483119/example-of-how-to-use-getopts-in-bash

MODE="c"
CRF=22

while getopts ":2:c:" option; do
    case $option in
        2)
			MODE="2"
            ;;
        c)
			MODE="c"
			# If $OPTARG is not empty (-z), ensure that $OPTARG is an integer in the range [17, 27]
			# (we may need ro use bc to check this),
			# and then pass it to ffmpeg as the constant rate factor.

			# If $OPTARG is not parseable as an integer, Bash will throw an error, which will be trapped.
			
			if ! [ -z $OPTARG ] && [ $OPTARG -ge 17 ] && [ $OPTARG -le 27 ]; then
				CRF=$OPTARG
			fi
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

# Get file extension: see http://tecadmin.net/how-to-extract-filename-extension-in-shell-script/
FILENAME_WITH_EXTENSION=$(basename "$1")
EXTENSION="${FILENAME_WITH_EXTENSION##*.}" # If FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of FILENAME_WITH_EXTENSION

# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
FILENAME=$(basename -s ."$EXTENSION" "$1")

AUDIO_CODEC="aac"
VIDEO_CODEC="libx264"

case $MODE in
	2)
		echo "Something other than Constant Rate Factor (CRF)"
		echo "Two-pass"
		AUDIO_BITRATE="128k"
		VIDEO_BITRATE="555k"
		# Are we running on Windows or *nix? "uname -a" and "awk" should be able to tell us:
		# - On Win10 Cygwin: "uname -a" generates: CYGWIN_NT-10.0 ... 2.6.0(0.304/5/3) 2016-08-31 14:32 x86_64 Cygwin
		#   - uname -a | awk '{print $NF}' -> "Cygwin"
		# - On Win10 Bash: "uname -a" generates: Linux ... 3.4.0+ #1 PREEMPT Thu Aug 1 17:06:05 CST 2013 x86_64 x86_64 x86_64 GNU/Linux
		#   - uname -a | awk '{print $NF}' -> "GNU/Linux"
		#
		# See https://stackoverflow.com/questions/3466166/how-to-check-if-running-in-cygwin-mac-or-linux

		# OS_TYPE=$(uname -a | awk '{print $NF}')
		# OS_TYPE=$(uname -o)
		# echo "OS_TYPE is $OS_TYPE"
		
		# if [ $OS_TYPE == "Cygwin" ]; then
		if [ $(distro_is_cygwin) ]; then
			NULL_DEVICE="NUL" # "NUL" on Windows; "/dev/null" on Linux, etc.
		else
			NULL_DEVICE="/dev/null"
		fi

		echo "NULL_DEVICE is $NULL_DEVICE"
		ffmpeg -y -i "$1" -c:v $VIDEO_CODEC -preset medium -b:v $VIDEO_BITRATE -pass 1 -c:a $AUDIO_CODEC -b:a $AUDIO_BITRATE -f mp4 $NULL_DEVICE && \
			ffmpeg -i "$1" -c:v $VIDEO_CODEC -preset medium -b:v $VIDEO_BITRATE -pass 2 -c:a $AUDIO_CODEC -b:a $AUDIO_BITRATE "$FILENAME.mp4"
		;;
	c)
		echo "Constant Rate Factor (CRF)"
		# CRF: Can we re-encode the audio, or must we just copy it?
		
		if [ $CRF != 22 ]; then
			FILENAME="${FILENAME}_crf$CRF"
		fi
		
		# echo "ffmpeg -i $1 -c:v $VIDEO_CODEC -preset slow -crf $CRF -c:a copy $FILENAME.mp4"
		ffmpeg -i "$1" -c:v $VIDEO_CODEC -preset slow -crf $CRF -c:a copy "$FILENAME.mp4" # || error_exit "ffmpeg returned an error: $?"
		;;
	*)
		usage
		error_exit "Bad mode; toast."
esac

EXIT_STATUS=$?

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "ffmpeg experienced an error."
fi

clean_up $EXIT_STATUS
