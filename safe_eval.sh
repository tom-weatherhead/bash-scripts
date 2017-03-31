#!/bin/bash

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME command"
	echo_error_message
	echo_error_message "E.g. $PROGRAM_NAME \"ls -l ~\""
	echo_error_message
}

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "1 argument expected; $# arguments received."
fi

safe_eval()
{
	# TODO: ThAW 2017/03/28 : Take an optional argument $2, and set CMD=$2 if $2 is not empty. Otherwise, run the CMD=... line below.
	# Or: $2 could be an array of command names (strings) to check with "which".
	CMD=$(echo $1 | awk '{print $1}')
	
	# if which $CMD 1>/dev/null 2>&1; then
	if which $CMD >/dev/null 2>&1; then
		eval $1
	else
		echo_error_message
		echo_error_message "The command '$CMD' was not found in the path."
		echo_error_message "To view the path, execute this command: echo \$PATH"
		clean_up 1
	fi
}

safe_eval "$1"
