#!/bin/bash

PROGRAM_NAME=$(basename "$0")

echo_error_message()
{
	# echo $1 1>&2
	echo $1 2>&1
}

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME command"
	echo_error_message
	echo_error_message "E.g. $PROGRAM_NAME \"ls -l ~\""
	echo_error_message
}

clean_up()
{
	# Perform end-of-execution housekeeping
	# Optionally accepts an exit status
	exit $1
}

error_exit()
{
	# Display an error message and exit
	echo_error_message "${PROGRAM_NAME}: Error: ${1:-"Unknown Error"}"
	clean_up 1
}

trap clean_up SIGHUP SIGINT SIGTERM

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "1 argument expected; $# arguments received."
fi

safe_eval()
{
	CMD=$(echo $1 | awk '{print $1}')
	
	if which $CMD 1>/dev/null 2>&1; then
		eval $1
	else
		echo_error_message
		echo_error_message "The command '$CMD' was not found in the path."
		echo_error_message "To view the path, execute this command: echo \$PATH"
		clean_up 1
	fi
}

safe_eval "$1"
