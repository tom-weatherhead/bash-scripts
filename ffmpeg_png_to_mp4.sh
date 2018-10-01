#!/bin/bash

# ffmpeg: Combine a set of .png image files in to an .mp4 video file

DSTFILEPATH="$1"

# TODO: If $DSTFILEPATH does not end with .mp4, append .mp4 to it.

FRAMERATE=30
STARTNUMBER=1
TITLE="Title"	# TODO.
PRESET="veryslow"
CRF=10
NUM_THREADS=1
THREADS_OPTION="-threads $NUM_THREADS"

# -an means: No audio.
# -sn means: No subtitles.

# ffmpeg -hide_banner -framerate 30 -start_number n -i frame%04d.png -map_metadata 0 -map_chapters 0 -metadata title="Title" -vf "yadif,format=yuv420p" -c:v libx264 -preset veryslow -crf 10 -an -sn -threads 1 "$DSTFILEPATH"
ffmpeg -hide_banner -framerate $FRAMERATE -start_number $STARTNUMBER -i frame%04d.png -map_metadata 0 -map_chapters 0 -metadata title="Title" -vf "yadif,format=yuv420p" -c:v libx264 -preset $PRESET -crf $CRF -an -sn $THREADS_OPTION "$DSTFILEPATH"
