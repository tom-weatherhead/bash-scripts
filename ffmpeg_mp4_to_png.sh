#!/bin/bash

# ffmpeg: Extract each frame in an .mp4 file as a .png file

SRCFILEPATH="$1"

ffmpeg -i "$SRCFILEPATH" frame%04d.png -hide_banner
