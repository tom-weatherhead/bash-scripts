#!/bin/bash

# script_template.sh

PROGRAM_NAME=$(basename "$0")

echo_error_message()
{
	# 1>&2 or 2>&1 ? -> 2>&1 !
	# https://www.google.ca/search?q=linux+1%3E%262+vs+2%3E%261
	# https://superuser.com/questions/436586/why-redirect-output-to-21-and-12

	echo $1 2>&1
}

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "This is the usage message for $PROGRAM_NAME ."
	echo_error_message
}

clean_up()
{
	# Perform end-of-execution housekeeping
	# Optionally accepts an exit status
	echo "Cleaning up: Exiting with status $1."
	exit $1
}

error_exit()
{
	# Display an error message and exit
	echo_error_message "$PROGRAM_NAME: Error: ${1:-"Unknown Error"}"
	clean_up 1
}

which_test()
{
	which $1 1>/dev/null 2>&1 && {
		echo "Command '$1' found."
	} || {
		error_exit "Command '$1' not found; exiting."
	}
}

echo_option_info()
{
	#if [ -z $2 ]; then
	#	echo "Option -$1 detected with no value."
	#else
	#	echo "Option -$1 detected with value '$2'."
	#fi
	[ -z $2 ] && {
		echo "Option -$1 detected with no value."
	} || {
		echo "Option -$1 detected with value '$2'."
	}
}

check_directory()
{
	# This is the original version:
	
	#if ! [ -e "$1" ]; then # We need to use "$1" instead of $1 , in case $1 contains whitespace.
	#	error_exit "$1 does not exist."
	#elif ! [ -d "$1" ]; then
	#	error_exit "$1 is not a directory."
	#elif ! [ -w "$1" ]; then
	#	error_exit "$1 is not writable by the current user."
	#fi

	# This works:
	
	#! [ -e "$1" ] && { # We need to use "$1" instead of $1 , in case $1 contains whitespace.
	#	error_exit "$1 does not exist."
	#} || ! [ -d "$1" ] && {
	#	error_exit "$1 is not a directory."
	#} || ! [ -w "$1" ] && {
	#	error_exit "$1 is not writable by the current user."
	#}

	# This works too:
	
	[ -e "$1" ] || { # We need to use "$1" instead of $1 , in case $1 contains whitespace.
		error_exit "$1 does not exist."
	} && [ -d "$1" ] || {
		error_exit "$1 is not a directory."
	} && [ -w "$1" ] || {
		error_exit "$1 is not writable by the current user."
	}
}

echo_and_eval()
{
	echo $@
	eval $@
}

trap clean_up SIGHUP SIGINT SIGTERM

# which_test required_command_1
# which_test required_command_2
# which_test required_command_3

# while getopts ":a" option; do # Option -a must not be followed by a value.
# while getopts ":a:" option; do # Option -a must be followed by a value.
# while getopts ":a:b" option; do # Option -a must be followed by a value; option -b must not be followed by a value. They may be passed together as -ba value
while getopts ":ab:" option; do # Option -a must not be followed by a value; option -b must be followed by a value. They may be passed together as -ab value
# while getopts ":ab" option; do # Both option -a and option -b must not be followed by a value. They may be passed together as -ab
# while getopts ":a::b:" option; do # Both option -a and option -b must be followed by a value.
    case $option in
        a)
			echo_option_info $option $OPTARG
			# Handle option -a
            ;;
        b)
			echo_option_info $option $OPTARG
			# Handle option -b
            ;;
		*)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
done

shift $((OPTIND -1))

EXPECTED_NUMBER_OF_ARGUMENTS=1

if [ $# != $EXPECTED_NUMBER_OF_ARGUMENTS ]; then # Using != instead of -ne
	usage
	error_exit "$EXPECTED_NUMBER_OF_ARGUMENTS argument(s) was/were expected; $# argument(s) was/were received."
fi

check_directory "$1"

# THE_COMMAND="df -h"
# THE_COMMAND="echo 'Hello world!'"
THE_COMMAND="echo \"Hello world!\""
#THE_COMMAND="ls /x"

echo_and_eval $THE_COMMAND

EXIT_STATUS=$?

echo "The command exited with the status $EXIT_STATUS."

if [ $EXIT_STATUS != 0 ]; then
	echo "The exit status indicates an error."
fi

clean_up $EXIT_STATUS
