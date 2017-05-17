#!/bin/bash

# See https://stackoverflow.com/questions/14005110/how-to-split-a-video-using-ffmpeg-so-that-each-chunk-starts-with-a-key-frame

# -> ffmpeg -i input.h265.aac.medium.crf28.mp4 -ss 47:00 -t 52:00 -acodec copy -f segment -vcodec copy -reset_timestamps 1 -map 0 segment%d.mp4

# The latest builds of FFMPEG include a new option "segment" which does exactly what I think you need.

# ffmpeg -i INPUT.mp4 -acodec copy -f segment -vcodec copy -reset_timestamps 1 -map 0 OUTPUT%d.mp4

# This produces a series of numbered output files which are split into segments based on Key Frames. In my own testing, it's worked well, although I haven't used it on anything longer than a few minutes and only in MP4 format.

# answered Jan 30 '14 at 6:25
# Tim Bull

# Some more examples: ffmpeg.org/ffmpeg-formats.html#Examples-5 – zanetu Mar 28 '15

ffmpeg -i "$1" -acodec copy -f segment -vcodec copy -reset_timestamps 1 -map 0 "$1.Segment%06d.mp4"

# ffmpeg -ss start_time -i "$1" -t length_of_desired_excerpt -acodec copy -f segment -vcodec copy -reset_timestamps 1 -map 0 "$1.Segment%06d.mp4"
# E.g. : ffmpeg -ss 01:12:35 -i "$1" -t 00:01:00 -acodec copy -f segment -vcodec copy -reset_timestamps 1 -map 0 "$1.Segment%06d.mp4"
