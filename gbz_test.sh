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

git archive --format=tar HEAD | bzip2 -9 - > "../$CURRENT_DIR_NAME_$(date --utc -Idate).tar.bz2"
