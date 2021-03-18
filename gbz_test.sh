#!/bin/bash

# A test of the functionality of the "gbz" alias to create a .tar.bz2 archive of the HEAD of the current branch of the current Git repository.

PWD=$(pwd)

[ -d .git ] || { echo "No .git subdirectory detected in $PWD; exiting."; exit 1; }

CURRENT_DIR_NAME=$(basename "$PWD")

# From the man page for "date" :

# -I[FMT], --iso-8601[=FMT]
              # output  date/time  in ISO 8601 format.  FMT='date' for date only
              # (the default), 'hours', 'minutes', 'seconds', or 'ns'  for  date
              # and    time    to    the    indicated    precision.     Example:
              # 2006-08-14T02:34:56-06:00

# DATE_TIME_STRING=$(date -u -Idate)
DATE_TIME_STRING=$(date -u +%Y-%m-%d_%H-%M-%S)

# TODO: Is HEAD necessary below, or it the default value?
git archive --format=tar HEAD | bzip2 -9 - > "../${CURRENT_DIR_NAME}_$DATE_TIME_STRING.tar.bz2"

# git archive --format=tar HEAD | gpg -r foo -e -o "../${CURRENT_DIR_NAME}_$DATE_TIME_STRING.tar.gpg"

# alias gbz='[ -d .git ] && { git archive --format=tar HEAD | bzip2 -9 - > "../$(basename $(pwd))_$(date -u +%Y-%m-%d_%H-%M-%S).tar.bz2"; } || { echo "No .git subdirectory detected."; }'
