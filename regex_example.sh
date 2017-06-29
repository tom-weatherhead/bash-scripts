#!/bin/bash

# Reference articles:
# See http://www.computerworld.com/article/2693361/unix-tip-using-bash-s-regular-expressions.html
# -> Alias of http://www.networkworld.com/article/2693361/unix-tip-using-bash-s-regular-expressions.html ?
# See https://www.linuxjournal.com/content/bash-regular-expressions
# See https://unix.stackexchange.com/questions/20804/in-a-regular-expression-which-characters-need-escaping

# [[ $(pwd) =~ ^/([a-z]+)/([a-z]) ]] && {
	# MOUNTS_DIR=${BASH_REMATCH[1]}
	# SRC_PATH="/$MOUNTS_DIR/${BASH_REMATCH[2]}/"
	# DEST_PATH="/$MOUNTS_DIR/$1"
# } || {
	# error_exit "Failed to find the root directory of the current drive."
# }

# ****

# ffmpeg -i C\:\\NoArchiv\\Test.mp4

TESTMP4=$(ffmpeg -i C\:\\NoArchiv\\Test.mp4 2>&1)

# echo $TESTMP4

# if [[ $(ffmpeg -i C\:\\NoArchiv\\Test.mp4 2>&1 | grep Audio) ]]; then echo "Yay!"; fi

# if [[ $(ffmpeg -i C\:\\NoArchiv\\Test.mp4 2>&1 =~ Audio ) ]]; then echo "Yay!"; fi

# if [[ $(ffmpeg -i C\:\\NoArchiv\\Test.mp4 2>&1 =~ Stream #([0-9]:[0-9]).*: Audio ) ]]; then echo "Yay! ${BASH_REMATCH[1]}"; fi
 
# if [[ $TESTMP4 =~ Stream\s*.([0-9]\:[0-9]).*\:\s*Audio ]]; then echo "Yay! ${BASH_REMATCH[1]}"; fi

# if [[ 'abc#def' =~ '#' ]]; then echo "Yay! Octothorpe."; else echo "No octo."; fi

# if [[ 'abc#def' =~ '#' ]]; then echo "Yay! Octothorpe."; else echo "No octo."; fi

# if [[ 'abc#def' =~ ^abc'#'d ]]; then echo "Yay! Octothorpe."; else echo "No octo."; fi

# if [[ $TESTMP4 =~ '#' ]]; then echo "Yay! .mp4"; else echo "Non. .mp4"; fi

# if [[ $TESTMP4 =~ '#' ]]; then echo "Yay! .mp4"; else echo "Non. .mp4"; fi

# if [[ $TESTMP4 =~ "Stream #0:0(und): Video: h264" ]]; then echo "Yay! .mp4 stream 0:0"; else echo "Non. .mp4 stream 0:0"; fi

# if [[ 'a:b c#d(foo) ef' =~ "a:b c#d(f" ]]; then echo "Yay! Octothorpe."; else echo "No octo."; fi

# if [[ 'abcdefg' =~ ab([a-z]{3})fg ]]; then echo "Yay! 3 characters: ${BASH_REMATCH[1]}"; else echo "Non. 3 characters."; fi

# if [[ 'a#bcdefg' =~ a.b([a-z]{3})fg ]]; then echo "Yay! 3 characters 2: ${BASH_REMATCH[1]}"; else echo "Non. 3 characters 2."; fi

# if [[ 'a #bcdefg' =~ a' #'b([a-z]{3})fg ]]; then echo "Yay! 3 characters 3: ${BASH_REMATCH[1]}"; else echo "Non. 3 characters 3."; fi

if [[ $TESTMP4 =~ Stream' #'([0-9]':'[0-9])'('([a-z]+)'): 'Video': '([a-zA-Z0-9]+)' ' ]]; then echo "Yay! .mp4 video stream : ${BASH_REMATCH[1]} : ${BASH_REMATCH[2]} : ${BASH_REMATCH[3]}"; else echo "Non. .mp4 video stream"; fi

if [[ $TESTMP4 =~ Stream' #'([0-9]':'[0-9])'('([a-z]+)'): 'Audio': '([a-zA-Z0-9]+)' ' ]]; then echo "Yay! .mp4 audio stream : ${BASH_REMATCH[1]} : ${BASH_REMATCH[2]} : ${BASH_REMATCH[3]}"; else echo "Non. .mp4 audio stream"; fi
