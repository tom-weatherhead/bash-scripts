#!/bin/bash

echo_and_eval()
{
	echo $@
	# echo "$@"
	eval $@
	# printf %q "$@"
	# $(printf %q "$@")
	# `printf %q "$@"`
}

# Hint: Escape the special characters just in the file paths, not in the entire command string that is passed to echo_and_eval.
# E.g. : "ls -l Test\ \(Doc\).txt" works, but "ls\ -l\ Test\ \(Doc\).txt" does not.

TESTFILENAME_UNESCAPED="test (doc).txt"

# See https://stackoverflow.com/questions/2854655/command-to-escape-a-string-in-bash
FOO1=$(printf %q $TESTFILENAME_UNESCAPED)
FOO2=$(printf %q "$TESTFILENAME_UNESCAPED")

echo $FOO1 # We don't want this; it eats spaces.
echo $FOO2 # We do want this.

# TESTFILENAME_ESCAPED="test\ \(doc\).txt"
TESTFILENAME_ESCAPED=$FOO2
# CMD1="ls -l"
CMD2="ls -l test\ \(doc\).txt"
CMD3="ls -l $TESTFILENAME_ESCAPED"
# CMD4="ls -l \"$TESTFILENAME_ESCAPED\""

echo_and_eval $CMD2

if [[ -e $TESTFILENAME_ESCAPED ]]; then # The double square brackets are necessary for Bash file tests such as -e
	echo_and_eval $CMD3
fi

# echo_and_eval "$CMD4" # On both WSL and Cygwin: ls: cannot access 'Test\ \(Doc\).txt': No such file or directory

# echo $#

# if [ $# ]; then # No.
if [ $# -gt 0 ]; then
	FOO5=$(printf %q "$1") # The double quotes around $1 are necessary.
	CMD5="ls -l $FOO5"
	echo_and_eval $CMD5
fi
