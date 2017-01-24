#!/bin/bash

# Use ffmpeg to resample a video to iPhone 6 resolution: 1334 x 750
# See https://en.wikipedia.org/wiki/IPhone_6
# See https://trac.ffmpeg.org/wiki/Scaling%20(resizing)%20with%20ffmpeg

# See http://gaborhargitai.hu/convert-videos-to-ipod-ipad-iphone-with-ffmpeg-under-ubuntu-or-mac-os-x/

# !!! See http://www.catswhocode.com/blog/19-ffmpeg-commands-for-all-needs
# - Encode a video sequence for the iPpod/iPhone

# ffmpeg -i source_video.avi input -acodec aac -ab 128kb -vcodec mpeg4 -b 1200kb -mbd 2 -flags +4mv+trell -aic 2 -cmp 2 -subcmp 2 -s 320x180 -title X final_video.mp4

# ??? What is the option -aic ? Apple Intermediate Codec (AIC) Decoder : See https://trac.ffmpeg.org/ticket/1770

# ffmpeg -i "$1" input -acodec aac -ab 128kb -vcodec mpeg4 -b 1200kb -mbd 2 -flags +4mv+trell -aic 2 -cmp 2 -subcmp 2 -s 320x180 -title X "${1}.iPhone.mp4"

# Explanations :
#
#    Source : source_video.avi
#    Audio codec : aac
#    Audio bitrate : 128kb/s
#    Video codec : mpeg4
#    Video bitrate : 1200kb/s
#    Video size : 320px par 180px
#    Generated video : final_video.mp4

# See https://trac.ffmpeg.org/wiki/Encode/H.264 :

# CRF Example
# ffmpeg -i input -c:v libx264 -preset slow -crf 22 -c:a copy output.mkv
# Note that in this example the audio stream of the input file is simply ​stream copied over to the output and not re-encoded. 

# iOS Compatability (​source)
# Profile 	Level 	Devices 	Options
# High 	4.2 	iPad Air and later, iPhone 5s and later 	-profile:v high -level 4.2

# ffmpeg -i "$1" -profile:v high -level 4.2 -c:v libx264 -preset slow -crf 22 -c:a copy "${1}.iPhone.H264.crf22.mp4"
ffmpeg -i "$1" -profile:v high -level 4.2 -c:v libx264 -preset slow -crf 27 -c:a copy "${1}.iPhone.H264.crf27.mp4"

# Note: streamcopy ("-c copy") cannot be used with filtering.

# TODO: Downsample only; do not upsample.

# ffmpeg -i "$1" -vf scale="'if(lt(a,4/3),1334,-1)':'if(lt(a,4/3),-1,750)'" "iPhone6_1334x750_$1"
