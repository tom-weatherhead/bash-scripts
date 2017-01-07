#!/bin/bash

# find_duplicate_files.sh - Find all duplicate files in a subtree of the file system - November 18, 2016

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
	echo_error_message "Usage: $PROGRAM_NAME path_to_root_of_subtree"
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

which_test()
{
	which $1 1>/dev/null 2>&1 && {
		echo "Command '$1' found."
	} || {
		echo_error_message
		echo_error_message "The command '$1' was not found in the path."
		echo_error_message "To view the path, execute this command: echo \$PATH"
		echo_error_message
		error_exit "Command '$1' not found; exiting."
	}
}

date_time_utc()
{
	echo "$(date --utc +'%F at %H:%M:%S') UTC"
}

# To send the signal "sig" to the process with PID "pid", run: kill -sig pid (e.g. kill -9 1234)

# PIDs (process IDs) can be found by running ps ; e.g. ps aux | grep firefox

# From https://www.tutorialspoint.com/unix/unix-signals-traps.htm :

# SIGHUP   1 Hang up detected on controlling terminal or death of controlling process
# SIGINT   2 Issued if the user sends an interrupt signal (Ctrl + c).
# SIGTERM 15 Software termination signal (sent by kill by default).

# Note: SIGKILL (signal 9) cannot be trapped.

# This trap command works on bash, but on Ubuntu 16.10, dash (via sh) complains: "trap: SIGHUP: bad trap" ; another reason to use #!/bin/bash instead of #!/bin/sh ?
# See e.g. https://lists.yoctoproject.org/pipermail/yocto/2013-April/013125.html
trap clean_up SIGHUP SIGINT SIGTERM

which_test find
which_test xargs
which_test sort
which_test uniq
which_test tr
which_test bc

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly one path must be specified as a command-line argument."
fi

REPORT_FILENAME=duplicate_files_report_$(date --utc +%Y%m%d_%H%M%S).txt
START_DATETIME=$(date_time_utc)

NEWLINE=$'\n' # See zvezda's solution in https://stackoverflow.com/questions/3005963/how-can-i-have-a-newline-in-a-string-in-sh
echo "Duplicate files report for the path $1$NEWLINE" > $REPORT_FILENAME
echo "Generated on $START_DATETIME UTC$NEWLINE" >> $REPORT_FILENAME

EXITCODE=0

# Use double quotes around $1 (find "$1"...) to protect against any spaces in the path in $1
# 2016/12/12 : Changed "sort -k1,32" to "sort"
find "$1" -type f -print0 | xargs --null md5sum | sort | uniq -D -w 32 >> $REPORT_FILENAME

# See https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another

if [ `echo "${PIPESTATUS[@]}" | tr -s ' ' + | bc` -ne 0 ]; then EXITCODE=1; echo_error_message "Error."; fi

echo "Done."
echo "Started on $START_DATETIME"
echo "Ended on   $(date_time_utc)"
echo "Exit code: $EXITCODE"

if [ $EXITCODE -eq 0 ]; then
	echo "Success!"
fi

clean_up $EXITCODE
