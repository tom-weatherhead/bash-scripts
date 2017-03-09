#!/bin/sh

# Match pattern from command line:

pattern="$1"

shift

awk '/'"$pattern"'/ { print FILENAME ":" $0 }' "$@"
