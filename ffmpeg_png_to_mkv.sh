#!/bin/bash

# ffmpeg: Combine a set of .png image files in to an .mkv video file

ffmpeg -framerate 10 -i 'frame%04d.png' output.mkv
