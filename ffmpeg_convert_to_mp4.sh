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

# AUDIO_CODEC="libmp3lame"
AUDIO_CODEC="aac"

VIDEO_CODEC="libx264"
CRF=22

MODE="c"

# To minimize CPU usage and fan noise, use -threads 1 and pools=1
# POOLS=1
POOLS=2
# POOLS=4

NUM_THREADS=1
				
# Using getopts to detect and handle command-line options : See https://stackoverflow.com/questions/16483119/example-of-how-to-use-getopts-in-bash

while getopts "245c:p:" option; do
    case $option in
        2)
			MODE="2"
            ;;
		4)
			VIDEO_CODEC="libx264"
			CRF=22
			;;
		5)
			# See https://superuser.com/questions/785528/how-to-generate-an-mp4-with-h-265-codec-using-ffmpeg
			VIDEO_CODEC="libx265"
			CRF=28
			;;
        c)
			MODE="c"
			# If $OPTARG is not empty (-z), ensure that $OPTARG is an integer in the range [17, 27]
			# (we may need ro use bc to check this),
			# and then pass it to ffmpeg as the constant rate factor.

			# If $OPTARG is not parseable as an integer, Bash will throw an error, which will be trapped.
			
			if ! [ -z $OPTARG ] && [ $OPTARG != "--" ] && [ $OPTARG -ge 17 ] && [ $OPTARG -le 27 ]; then
				CRF=$OPTARG
			fi
            ;;
		p) # Number of pools to use during x265 encoding
			# TODO: Verify that $OPTARG is a positive integer no greater than the system's number of CPU cores?
			# NUM_CPU_CORES=$(grep -c processor /proc/cpuinfo)
			POOLS=$OPTARG
			;;
		# t) # Number of threads (per pool?) to use during x265 encoding
			# TODO: Verify that $OPTARG is a positive integer: if [ $OPTARG -gt 0 ] ... fi ?
			# NUM_THREADS=$OPTARG
			# ;;
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

# echo "SOURCE_FILE_PATH is $SOURCE_FILE_PATH"
# echo "SOURCE_FILENAME_WITH_EXTENSION is $SOURCE_FILENAME_WITH_EXTENSION"
# echo "SOURCE_EXTENSION is $SOURCE_EXTENSION"
# echo "SOURCE_FILENAME_BASE is $SOURCE_FILENAME_BASE"

FFMPEG_INFO_OUTPUT=$(ffmpeg -i "$SOURCE_FILE_PATH" 2>&1)

echo "$FFMPEG_INFO_OUTPUT" | grep -q Audio:\ aac && {
	# The source audio stream is already encoded as AAC; just copy it.
	echo "The source audio stream is encoded as AAC; copying..."
	AUDIO_CODEC="copy"
	AUDIO_CODEC_IN_DEST_FILENAME="$AUDIO_CODEC"
} || {
	echo "The source audio stream is not encoded as AAC; transcoding to AAC..."

	# [[ "$FFMPEG_INFO_OUTPUT" =~ libfdk_aac ]] && {
	echo "$FFMPEG_INFO_OUTPUT" | grep -q libfdk_aac && {
		# The libfdk_aac codec is available.
		echo "libfdk_aac detected. Yay!"
		AUDIO_CODEC="libfdk_aac"
	} || {
		AUDIO_CODEC="aac"
	}

	echo "Using the $CODEC codec to transcode the audio stream to AAC..."

	AUDIO_KBPS_OUT="128"
	# AUDIO_KBPS_OUT="192"
	# AUDIO_KBPS_OUT="256"
	AUDIO_CODEC_IN_DEST_FILENAME="$AUDIO_CODEC.${AUDIO_KBPS_OUT}kbps"
	AUDIO_CODEC="$AUDIO_CODEC -b:a ${AUDIO_KBPS_OUT}k"
}

# PRESET="ultrafast"
# PRESET="superfast"
# PRESET="veryfast"
# PRESET="faster"
# PRESET="fast"
PRESET="medium"
# PRESET="slow"
# PRESET="slower"
# PRESET="veryslow"
# PRESET="placebo" # Don't use this.

START_TIME=$(date_time_utc)

case $MODE in
	2)
		echo "Something other than Constant Rate Factor (CRF) - Performing two-pass encoding..."
		
		VIDEO_CODEC="libx264" # Overide: Do not support encoding to anything other than h264.
		VIDEO_KBPS_OUT="555"

		if [ $(distro_is_cygwin) ]; then
			NULL_DEVICE="NUL" # "NUL" on Windows; "/dev/null" on Linux, etc.
		else
			NULL_DEVICE="/dev/null"
		fi

		echo "NULL_DEVICE is $NULL_DEVICE"

		DEST_FILENAME_WITH_EXTENSION="$SOURCE_FILENAME_BASE.h264.$AUDIO_CODEC_IN_DEST_FILENAME.$PRESET.2pass.mp4"
		# DEST_FILENAME_WITH_EXTENSION="$SOURCE_FILENAME_BASE.h264.$AUDIO_CODEC.$PRESET.crf${CRF}.mp4"

		ffmpeg -y -i "$SOURCE_FILE_PATH" -c:v $VIDEO_CODEC -preset $PRESET -b:v ${VIDEO_KBPS_OUT}k -pass 1 -c:a $AUDIO_CODEC -f mp4 $NULL_DEVICE && \
			ffmpeg -i "$SOURCE_FILE_PATH" -c:v $VIDEO_CODEC -preset $PRESET -b:v ${VIDEO_KBPS_OUT}k -pass 2 -c:a $AUDIO_CODEC "$DEST_FILENAME_WITH_EXTENSION"
		;;
	c)
		echo "Constant Rate Factor (CRF)"

		# Using printf %q to escape paths: See https://stackoverflow.com/questions/2854655/command-to-escape-a-string-in-bash

		# The number of CPU cores is:
		# NUM_CPU_CORES=$(grep -c processor /proc/cpuinfo)
		# So divide it by 2 and use it as the value of the "-threads" argument, but ensure that it is at least 1.
		# NUM_THREADS=$(( ${NUM_CPU_CORES}/2 ))
		# NUM_THREADS=$(( ${NUM_CPU_CORES}/4 ))
		# echo "Suggested number of threads: $NUM_THREADS"

		# THREADS_OPTION=""
		# THREADS_OPTION="-threads 1"
		# THREADS_OPTION="-threads 2"
		# THREADS_OPTION="-threads 4"
		THREADS_OPTION="-threads $NUM_THREADS"

		# Possible ffmpeg options:
		# - -map 0 : Map all streams from the first input file to output (from the ffmpeg man page)

		case $VIDEO_CODEC in
			libx264)
				# See https://trac.ffmpeg.org/wiki/Encode/H.264

				# EXTRA_OPTIONS="-crf $CRF" # Should this be called EXTRA_VIDEO_OPTIONS? When passing options to ffmpeg, the order of the options matters! We may want to separate EXTRA_OPTIONS into EXTRA_VIDEO_OPTIONS and EXTRA_AUDIO_OPTIONS.
				DEST_FILENAME_WITH_EXTENSION="$SOURCE_FILENAME_BASE.h264.$AUDIO_CODEC_IN_DEST_FILENAME.$PRESET.crf${CRF}.mp4"

				# TODO: Write code to detect the stream numbers of the audio, video, and subtitle streams; don't assume that video=0:0, audio=0:1, and subtitles=0:2. Use regexes to search the output of "ffmpeg -i".
				# Or... do not indicate the stream numbers of the source audio, video, and subtitle streams; e.g. :

				# We could insert the following lines between the -metadata title line and the -c:v line:
				# (This assumes that streams 0:0, 0:1, and 0:2 are video, audio, and subtitles respectively.)
				# -map 0:0 -metadata:s:v:0 language=eng \
				# -map 0:1 -metadata:s:a:0 language=eng -metadata:s:a:0 title=\"Advanced Audio Coding (AAC)\" \
				# -map 0:2? -metadata:s:s:0 language=eng -metadata:s:s:0 title=\"English\" \

				echo_and_eval $(printf "ffmpeg -hide_banner \
					-i %q \
					-map_metadata 0 \
					-map_chapters 0 \
					-metadata title=\"Title\" \
					-c:v libx264 -preset $PRESET \
					-crf $CRF \
					-c:a $AUDIO_CODEC \
					-c:s copy \
					$THREADS_OPTION \
					%q 2>&1" "$SOURCE_FILE_PATH" "$DEST_FILENAME_WITH_EXTENSION")
				;;

			libx265)
				# See https://trac.ffmpeg.org/wiki/Encode/H.265

				# - From https://unix.stackexchange.com/questions/230800/re-encoding-video-library-in-x265-hevc-with-no-quality-loss :
				# LOSSLESS_PARAM=""
				# LOSSLESS_PARAM="-x265-params lossless=1"
				# E.g. echo_and_eval $(printf "ffmpeg -i %q -c:v libx265 -preset ultrafast -x265-params lossless=1 %q" "$1" "$FILENAME.h265.mp4")
				
				# E.g. echo_and_eval $(printf "ffmpeg -i %q -c:v libx265 -preset slow -c:a $AUDIO_CODEC -an -x265-params crf=25 %q" "$1" "$FILENAME.h265.mp4") # What does -an do? -> Disable the selection of a default audio stream? See https://ffmpeg.org/ffmpeg.html

				DEST_FILENAME_WITH_EXTENSION="$SOURCE_FILENAME_BASE.h265.$AUDIO_CODEC_IN_DEST_FILENAME.$PRESET.crf${CRF}.mp4"

				# TODO: Write code to detect the stream numbers of the audio, video, and subtitle streams; don't assume that video=0:0, audio=0:1, and subtitles=0:2. Use regexes to search the output of "ffmpeg -i".
				# Or... do not indicate the stream numbers of the source audio, video, and subtitle streams; e.g. :

				# Based on Yifeng Mu's answer in https://unix.stackexchange.com/questions/230800/re-encoding-video-library-in-x265-hevc-with-no-quality-loss :

				# We could insert the following lines between the -metadata title line and the -c:v line:
				# (This assumes that streams 0:0, 0:1, and 0:2 are video, audio, and subtitles respectively.)
				# -map 0:0 -metadata:s:v:0 language=eng \
				# -map 0:1 -metadata:s:a:0 language=eng -metadata:s:a:0 title=\"Advanced Audio Coding (AAC)\" \
				# -map 0:2? -metadata:s:s:0 language=eng -metadata:s:s:0 title=\"English\" \

				echo_and_eval $(printf "ffmpeg -hide_banner \
					-i %q \
					-map_metadata 0 \
					-map_chapters 0 \
					-metadata title=\"Title\" \
					-c:v libx265 -preset $PRESET -x265-params \
					crf=${CRF}:pools=${POOLS}:qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 \
					-c:a $AUDIO_CODEC \
					-c:s copy \
					$THREADS_OPTION \
					%q 2>&1" "$SOURCE_FILE_PATH" "$DEST_FILENAME_WITH_EXTENSION")

				# ... And then, to verify the result:
				# ffmpeg -i "$OUTPUT_FILENAME" | grep hevc
				# ffmpeg -i "$OUTPUT_FILENAME" | grep aac
				
				# Or: (We might need to use $NULL_DEVICE from the two-pass case above in place of /dev/null in order to support Cygwin)
				# ffmpeg -i "$OUTPUT_FILENAME" 1>/dev/null | perl -nle 'print $1 if /Video: (\S+)\s/'
				# ffmpeg -i "$OUTPUT_FILENAME" 1>/dev/null | perl -nle 'print $1 if /Audio: (\S+)\s/'

				# **** BEGIN Useful post 1 : Yifeng Mu's answer at https://unix.stackexchange.com/questions/230800/re-encoding-video-library-in-x265-hevc-with-no-quality-loss ****

					# From my own experience, if you want absolutely no loss in quality, --lossless is what you are looking for.

					# Not sure about avconv but the command you typed looks identical to what I do with FFmpeg. In FFmpeg you can pass the parameter like this:

					# ffmpeg -i INPUT.mkv -c:v libx265 -preset ultrafast -x265-params lossless=1 OUTPUT.mkv

					# Most x265 switches (options with no value) can be specified like this (except those CLI-only ones, those are only used with x265 binary directly).

					# With that out of the way, I'd like to share my experience with x265 encoding. For most videos (be it WMV, or MPEG, or AVC/H.264) I use crf=23. x265 decides the rest of the parameters and usually it does a good enough job.

					# However often before I commit to transcoding a video in its entirety, I test my settings by converting a small portion of the video in question. Here's an example, suppose an mkv file with stream 0 being video, stream 1 being DTS audio, and stream 2 being a subtitle:				
					
					# ffmpeg -hide_banner \
						# -ss 0 \
						# -i "INPUT.mkv" \
						# -attach "COVER.jpg" \
						# -map_metadata 0 \
						# -map_chapters 0 \
						# -metadata title="TITLE" \
						# -map 0:0 -metadata:s:v:0 language=eng \
						# -map 0:1 -metadata:s:a:0 language=eng -metadata:s:a:0 title="Surround 5.1 (DTS)" \
						# -map 0:2 -metadata:s:s:0 language=eng -metadata:s:s:0 title="English" \
						# -metadata:s:t:0 filename="Cover.jpg" -metadata:s:t:0 mimetype="image/jpeg" \
						# -c:v libx265 -preset ultrafast -x265-params \
						# crf=22:qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 \
						# -c:a copy \
						# -c:s copy \
						# -t 120 \
						# "OUTPUT.HEVC.DTS.Sample.mkv"
						
					# Note that the backslashes signal line breaks in a long command, I do it to help me keep track of various bits of a complex CLI input. Before I explain it line-by-line, the part where you convert only a small portion of a video is the second line and the second last line: -ss 0 means seek to 0 second before starts decoding the input, and -t 120 means stop writing to the output after 120 seconds. You can also use hh:mm:ss or hh:mm:ss.sss time formats.

					# Now line-by-line:

					# 1. -hide_banner prevents FFmpeg from showing build information on start. I just don' want to see it when I scroll up in the console;
					# 2. -ss 0 seeks to 0 second before start decoding the input. Note that if this parameter is given after the input file and before the output file, it becomes an output option and tells ffmpeg to decode and ignore the input until x seconds, and then start writing to output. As an input option it is less accurate (because seeking is not accurate in most container formats), but takes almost no time. As an output option it is very precise but takes a considerable amount of time to decode all the stream before the specified time, and for testing purpose you don't want to waste time;
					# 3. -i "INPUT.mkv": Specify the input file;
					# 4. -attach "COVER.jpg": Attach a cover art (thumbnail picture, poster, whatever) to the output. The cover art is usually shown in file explorers;
					# 5. -map_metadata 0: Copy over any and all metadata from input 0, which in the example is just the input;
					# 6. -map_chapters 0: Copy over chapter info (if present) from input 0;
					# 7. -metadata title="TITLE": Set the title of the video;
					# 8. -map 0:0 ...: Map stream 0 of input 0, which means we want the first stream from the input to be written to the output. Since this stream is a video stream, it is the first video stream in the output, hence the stream specifier :s:v:0. Set its language tag to English;
					# 9. -map 0:1 ...: Similar to line 8, map the second stream (DTS audio), and set its language and title (for easier identification when choosing from players);
					# 10. -map 0:2 ...: Similar to line 9, except this stream is a subtitle;
					# 11. -metadata:s:t:0 ...: Set metadata for the cover art. This is required for mkv container format;
					# 12. -c:v libx265 ...: Video codec options. It's so long that I've broken it into two lines. This setting is good for high quality bluray video (1080p) with minimal banding in gradient (which x265 sucks at). It is most likely an overkill for DVDs and TV shows and phone videos. This setting is mostly stolen from this Doom9 post;
					# 13. crf=22:...: Continuation of video codec parameters. See the forum post mentioned above;
					# 14. -c:a copy: Copy over audio;
					# 15. -c:s copy: Copy over subtitles;
					# 16. -t 120: Stop writing to the output after 120 seconds, which gives us a 2-minute clip for previewing trancoding quality;
					# 17. "OUTPUT.HEVC.DTS.Sample.mkv": Output file name. I tag my file names with the video codec and the primary audio codec.

					# Whew. This is my first answer so if there is anything I missed please leave a comment. I'm not a video production expert, I'm just a guy who's too lazy to watch a movie by putting the disc into the player.

					# PS. Maybe this question belongs to somewhere else as it isn't strongly related to Unix & Linux.
					# shareimprove this answer
						
					# answered Dec 11 '15 at 5:28
					# Yifeng Mu
						
					# Q: Does this option generate the smallest possible file size for truly losless h265 encoding? If not, is there a way I can do this? – TheBitByte Nov 8 '16 at 17:02
						
					# A: @TheBitByte Yes and no, I think. You don't want lossless h265 files. It's just raw bit stream without any kind of compression. It's huge. From what I understand about h265 or specifically x265 implementation, it is not a lossless compression method. Any degree of compression will result in loss of information, but not necessarily loss of viewing quality. But I'm not an expert on h265 topics, so it's possible that I missed something – Yifeng Mu Dec 4 '16 at 3:55 					

				# **** END Useful post 1 : Yifeng Mu's answer at https://unix.stackexchange.com/questions/230800/re-encoding-video-library-in-x265-hevc-with-no-quality-loss ****

				;;

			*)
				error_exit "Unrecognized video codec: -$OPTARG"
		esac

		;;
	*)
		usage
		error_exit "Bad mode; toast."
esac

EXIT_STATUS=$?

FINISH_TIME=$(date_time_utc)

echo "Started at:  $START_TIME"
echo "Finished at: $FINISH_TIME"

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "ffmpeg experienced an error."
fi

clean_up $EXIT_STATUS
