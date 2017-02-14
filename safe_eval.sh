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
