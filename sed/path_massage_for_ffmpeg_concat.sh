#!/bin/bash
# pwd | sed -rn 's/^\/cygdrive\/(.)/\1:/;s/^\/mnt\/(.)/\1:/;s/\//\\\\/pg'
pwd | sed -rn 's/^\/(cygdrive|mnt)\/(.)/\U\2:/;s/\//\\\\/pg'
