#!/bin/bash

# See https://ffmpeg.org/ffmpeg-filters.html
# See https://ffmpeg.org/ffmpeg-filters.html#yadif
# See https://video.stackexchange.com/questions/17396/how-to-deinterlacing-with-ffmpeg

# ffmpeg -i input.vob -c:v libx264 -preset slow -crf 19 -c:a aac -b:a 256k -threads 0 output.mp4

FILENAME="$1"
# EXTENSION="$2" || "vob"
EXTENSION="$2"

if [ -z "$EXTENSION" ]; then
	EXTENSION="vob"
fi

boom () {
	echo $1
	echo "ffmpeg -i $FILENAME.$EXTENSION -vf $1 -c:v libx264 -preset slow -crf 19 -c:a aac -b:a 256k $FILENAME.$1.mp4"
	# ffmpeg -i "$FILENAME.vob" -vf $1 -c:v libx264 -preset slow -crf 19 -c:a aac -b:a 256k "$FILENAME.$1.mp4"
	echo
}

echo

# "bwdif" stands for "Bob Weaver Deinterlacing Filter" https://ffmpeg.org/ffmpeg-filters.html#toc-bwdif
boom bwdif

# kerndeint: Deinterlace input video by applying Donald Graft’s adaptive kernel deinterling. Work on interlaced parts of a video to produce progressive frames. https://ffmpeg.org/ffmpeg-filters.html#toc-kerndeint
boom kerndeint

# mcdeint is motion-compensation deinterlacing. https://ffmpeg.org/ffmpeg-filters.html#toc-mcdeint
boom mcdeint

# nnedi: Deinterlace video using neural network edge directed interpolation. https://ffmpeg.org/ffmpeg-filters.html#toc-nnedi

# This filter accepts the following options:

# weights

    # Mandatory option, without binary file filter can not work. Currently file can be found here: https://github.com/dubhater/vapoursynth-nnedi3/blob/master/src/nnedi3_weights.bin

# boom nnedi
ffmpeg -i "$FILENAME.$EXTENSION" -t 00:15 -map 0:0 -map 0:1 -vf "nnedi=weights=nnedi3_weights.bin" -c:v libx264 -preset slow -crf 19 -c:a aac -b:a 256k "$FILENAME.nnedi.mp4"

# w3fdif: "w3fdif" stands for "Weston 3 Field Deinterlacing Filter". https://ffmpeg.org/ffmpeg-filters.html#toc-w3fdif
boom w3fdif

# "yadif" means "yet another deinterlacing filter" https://ffmpeg.org/ffmpeg-filters.html#toc-yadif-1
boom yadif

# Note: idet: Detect video interlacing type.  https://ffmpeg.org/ffmpeg-filters.html#toc-idet
# ffmpeg -vf idet -frames:v 5000 -an -f rawvideo -y /dev/null -i ~/Downloads/clip.mpg

# From https://www.linkedin.com/pulse/20140614163714-67915895-detect-whether-a-video-is-truly-interlaced/ :

# ffmpeg -t 00:01:00 -i input.mpg -map 0:0 -vf idet -c rawvideo -y -f rawvideo /dev/null
# On Cygwin: ffmpeg -t 00:01:00 -i input.mpg -map 0:0 -vf idet -c rawvideo -y -f rawvideo NUL

# The output looks like this:
# [idet @ 0x17d10a0] Single frame detection: TFF:32 BFF:0 Progressive:0 Undetermined:42
# [idet @ 0x17d10a0] Multi frame detection: TFF:58 BFF:0 Progressive:0 Undetermined:16 
