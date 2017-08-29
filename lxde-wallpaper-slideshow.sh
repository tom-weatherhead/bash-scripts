#!/bin/bash

# LXDE wallpaper slideshow script
# From https://maubuntu.wordpress.com/2013/10/10/automatic-wallpaper-changing-script-for-lxde/
# (see dj's comment on May 1, 2014 at 10:52 am)

# DEFAULT_WALLPAPER_SLIDESHOW_DIR="$HOME/Pictures"
# WALLPAPER_SLIDESHOW_DIR="$DEFAULT_WALLPAPER_SLIDESHOW_DIR"

# if [ -z "$1" ]; then
	# echo "No parameter."
# elif ! [ -d "$1" ]; then
	# echo "$1 is not a directory."
# else
	# echo "$1 is a directory."
	# WALLPAPER_SLIDESHOW_DIR="$1"
# fi

# DIR="$HOME/Pictures"
# chmod 500 "$DIR"
# chmod 400 "$DIR/*"

# while true; do
	# pcmanfm --set-wallpaper="$(find $WALLPAPER_SLIDESHOW_DIR -type f | shuf -n1)"
	# sleep 3h
	# sleep 1m
# done

# Run by cron.
# Create and edit your account's crontab via: crontab -echo
export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"
pcmanfm -w "$(find /usr/share/thaw/public/wallpapers -type f | shuf -n1)"
# pcmanfm -w "$(find /usr/share/thaw/public/wallpapers -type f | shuf -n1)" --wallpaper-mode=fit
