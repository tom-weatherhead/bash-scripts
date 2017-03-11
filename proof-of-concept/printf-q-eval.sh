#!/bin/bash

# No: eval does not read its command string from stdin. See https://unix.stackexchange.com/questions/138446/eval-used-with-piped-command
# printf "ls -l %q" "$1" | eval

eval $(printf "ls -l %q" "$1")

CMD=$(printf "ls -l %q" "$1")
echo $CMD
eval $CMD
