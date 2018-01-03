#!/bin/bash

# Note: idet: Detect video interlacing type.  https://ffmpeg.org/ffmpeg-filters.html#toc-idet
# ffmpeg -vf idet -frames:v 5000 -an -f rawvideo -y /dev/null -i ~/Downloads/clip.mpg

# From +https://www.linkedin.com/pulse/20140614163714-67915895-detect-whether-a-video-is-truly-interlaced/ :

# ffmpeg -t 00:01:00 -i input.mpg -map 0:0 -vf idet -c rawvideo -y -f rawvideo /dev/null
# On Cygwin:

SOURCE_FILE_PATH="$1"
INPUT_VIDEO_STREAM_NUMBER="$2"

if [ -z "$INPUT_VIDEO_STREAM_NUMBER" ]; then
	INPUT_VIDEO_STREAM_NUMBER="0"
fi

# ffmpeg -t 00:01:00 -i input.mpg -map 0:0 -vf idet -c rawvideo -y -f rawvideo NUL

COMMAND=$(printf "ffmpeg -hide_banner \
	-t 00:01:00 \
	-i %q \
	-map 0:$INPUT_VIDEO_STREAM_NUMBER \
	-vf idet -c rawvideo -y -f rawvideo NUL \
	2>&1" \
	"$SOURCE_FILE_PATH")

echo $COMMAND
eval $COMMAND

# The output looks like this:
# [idet @ 0x17d10a0] Single frame detection: TFF:32 BFF:0 Progressive:0 Undetermined:42
# [idet @ 0x17d10a0] Multi frame detection: TFF:58 BFF:0 Progressive:0 Undetermined:16 
