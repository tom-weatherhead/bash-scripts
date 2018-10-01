#!/bin/bash

# ffmpeg: From .mkv to an .mp4 that is playable in Windows 10's "Films & TV" app
# This is suitable for an .mkv file that was constructed from a set of .png files.

SRCFILEPATH="$1"
DSTFILEPATH="output.mp4"

# TODO: Use -vf "yadif,format=yuv420p" ? yadif is a deinterlacing video filter.

ffmpeg -hide_banner -i "$SRCFILEPATH" -map_metadata 0 -map_chapters 0 -metadata title="Title" -vf format=yuv420p -c:v libx264 -preset medium -crf 22 -an -sn -threads 1 "$DSTFILEPATH"
