#!/bin/bash

- TODO: ffmpeg resample video to iPhone 6 resolution: 1334 x 750 : See https://en.wikipedia.org/wiki/IPhone_6
https://trac.ffmpeg.org/wiki/Scaling%20(resizing)%20with%20ffmpeg
 If you need to simply resize your video to a specific size (e.g 320x240), you can use the scale filter in its most basic form:

# E.g. ffmpeg -i "$1" -vf scale="'if(gt(a,4/3),1334,-1)':'if(gt(a,4/3),-1,750)'" "iPhone6_1334x750_$1"

ffmpeg -i input.avi -vf scale=320:240 output.avi

Same works for images too:

ffmpeg -i input.jpg -vf scale=320:240 output_320x240.png

 As you can see, the aspect ratio is not the same as in the original image, so the image appears stretched. If we'd like to keep the aspect ratio, we need to specify only one component, either width or height, and set the other component to -1. For example, this command line:

ffmpeg -i input.jpg -vf scale=320:-1 output_320.png

will set the width of the output image to 320 pixels and will calculate the height of the output image according to the aspect ratio of the input image. The resulting image will have a dimension of 320x207 pixels. 

 There are also some useful constants which can be used instead of numbers, to specify width and height of the output image. For example, if you want to stretch the image in such a way to only double the width of the input image, you can use something like this (iw = input width constant, ih = input height constant):

ffmpeg -i input.jpg -vf scale=iw*2:ih input_double_width.png

 If you want to half the size of the picture, just multiply by .5

ffmpeg -i input.jpg -vf scale=iw*.5:ih*.5 input_half_size.png

Sometimes there is a need to scale the input image in such way it fits into a specified rectangle, i.e. if you have a placeholder (empty rectangle) in which you want to scale any given image. This is a little bit tricky, since you need to check the original aspect ratio, in order to decide which component to specify and to set the other component to -1 (to keep the aspect ratio). For example, if we would like to scale our input image into a rectangle with dimensions of 320x240, we could use something like this:

ffmpeg -i input.jpg -vf scale="'if(gt(a,4/3),320,-1)':'if(gt(a,4/3),-1,240)'" output_320x240_boxed.png

 The area below the image is shaded with boxes to show there was some additional space left in the box, due to the original image not having the same aspect ratio as the box, in which the image was supposed to fit.

Of course, this approach is only used when your input image is not known in advance, because if it was known, you would easily figure out if you need to use either:

-vf scale=320:-1

or

-vf scale=-1:240

However, you can also achieve this with the force_original_aspect_ratio option. From the documentation:

    One useful instance of this option is that when you know a specific device's maximum allowed resolution, you can use this to limit the output video to that, while retaining the aspect ratio. For example, device A allows 1280x720 playback, and your video is 1920x800. Using this option (set it to decrease) and specifying 1280x720 to the command line makes the output 1280x533.

This allows you to force the image to fit into a 320x240 box:

ffmpeg -i input.jpg -vf scale=w=320:h=240:force_original_aspect_ratio=decrease output_320.png

This produces our 320x207 image that we had seen before: 
