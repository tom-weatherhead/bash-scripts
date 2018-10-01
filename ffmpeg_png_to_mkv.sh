#!/bin/bash

# ffmpeg: Combine a set of .png image files in to an .mkv video file

# ffmpeg -framerate 10 -start_number n -i 'frame%04d.png' output.mkv
# ffmpeg -framerate 10 -start_number n -i frame%04d.png output.mkv

# .png to .mp4 ? :
# ffmpeg -hide_banner -framerate 10 -start_number n -i frame%04d.png -map_metadata 0 -map_chapters 0 -metadata title="Title" -vf format=yuv420p -c:v libx264 -preset medium -crf 22 -an -sn -threads 1 "$DSTFILEPATH"
# ffmpeg -hide_banner -framerate 10 -start_number n -i frame%04d.png -map_metadata 0 -map_chapters 0 -metadata title="Title" -vf "yadif,format=yuv420p" -c:v libx264 -preset medium -crf 22 -an -sn -threads 1 "$DSTFILEPATH"
# ffmpeg -hide_banner -framerate 10 -start_number n -i frame%04d.png -map_metadata 0 -map_chapters 0 -metadata title="Title" -vf "yadif,format=yuv420p" -c:v libx264 -preset veryslow -crf 17 -an -sn -threads 1 "$DSTFILEPATH"
# ffmpeg -hide_banner -framerate 30 -start_number n -i frame%04d.png -map_metadata 0 -map_chapters 0 -metadata title="Title" -vf "yadif,format=yuv420p" -c:v libx264 -preset veryslow -crf 10 -an -sn -threads 1 "$DSTFILEPATH"

ffmpeg -framerate 10 -i 'frame%04d.png' output.mkv
# ffmpeg -hide_banner -framerate 10 -i 'frame%04d.png' output.mkv
