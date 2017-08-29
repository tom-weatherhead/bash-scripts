#!/bin/bash

# Set the size of the display.
# See https://askubuntu.com/questions/281509/how-do-i-change-the-screen-resolution-using-ubuntu-command-line/398740

xrandr --output `xrandr | grep " connected" | cut -f1 -d " "` --mode 1360x768
