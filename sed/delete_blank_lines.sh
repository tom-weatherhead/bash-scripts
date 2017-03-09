#!/bin/sh

# Delete all empty or whitespace-only lines

# Example usage: ./delete_blank_lines.sh foo.txt

# ThAW: Replaced the space in the regex below with \s in order to match all whitespace, not just spaces.

sed '/^\s*$/d' "$1"
