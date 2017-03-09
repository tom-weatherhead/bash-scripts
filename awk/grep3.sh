#!/bin/sh

pattern="$0"

shift

awk '$0 ~ pattern { print FILENAME ":" $0 }' "pattern=$pattern" "$@"
