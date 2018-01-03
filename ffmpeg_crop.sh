#!/bin/bash

# See http://www.bogotobogo.com/FFMpeg/ffmpeg_cropping_video_image.php

# The command syntax looks like this:
	
ffmpeg -i before.mp4 -vf "crop=w:h:x:y" after.mp4

# The crop filter accepts the following options:

    # w : Width of the output video (out_w). It defaults to iw. This expression is evaluated only once during the filter configuration.
    # h : Height of the output video (out_h). It defaults to ih. This expression is evaluated only once during the filter configuration.
    # x : Horizontal position, in the input video, of the left edge of the output video. It defaults to (in_w-out_w)/2. This expression is evaluated per-frame.
    # y:  Vertical position, in the input video, of the top edge of the output video. It defaults to (in_h-out_h)/2. This expression is evaluated per-frame.
