#!/bin/sed -f
# Remove newlines from sentences where the second line starts with one space:
N
s/\n\s\s*/ /
P
D