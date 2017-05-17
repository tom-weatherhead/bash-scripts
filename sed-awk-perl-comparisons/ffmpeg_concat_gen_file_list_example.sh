#!/bin/bash

# NEW_MP4_BASE_FILENAME=$(basename $(pwd))

# Using sed:
# Was: ls -w 40 ...
ls -w 1 *.mp4 | sed -rn 's/^(.*)$/file \x27X:\\dir1\\dir2\\dir3\\\1\x27/p' > FileList.Sed.txt

# Using awk:
ls -w 1 *.mp4 | awk '{ print "file '\''X:\\dir1\\dir2\\dir3\\" $0 "'\''" }' > FileList.Awk.txt

# Using perl:
ls -w 1 *.mp4 | perl -nle 'print "file '\''Z:\\dir1\\dir2\\dir3\\$_'\''";' > FileList.Perl.txt
