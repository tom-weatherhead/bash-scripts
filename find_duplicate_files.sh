#!/bin/bash

# find_duplicate_files.sh - Find all duplicate files in a subtree of the file system - November 18, 2016

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME path_to_root_of_subtree"
	echo_error_message
}

# To send the signal "sig" to the process with PID "pid", run: kill -sig pid (e.g. kill -9 1234)

# PIDs (process IDs) can be found by running ps ; e.g. ps aux | grep firefox

# From https://www.tutorialspoint.com/unix/unix-signals-traps.htm :

# SIGHUP   1 Hang up detected on controlling terminal or death of controlling process
# SIGINT   2 Issued if the user sends an interrupt signal (Ctrl + c).
# SIGTERM 15 Software termination signal (sent by kill by default).

# Note: SIGKILL (signal 9) cannot be trapped.

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

# NEWLINE=$'\n' # See zvezda's solution in https://stackoverflow.com/questions/3005963/how-can-i-have-a-newline-in-a-string-in-sh
# Use echo with the -e option so that \n is correctly interpeted as a newline.
# Compare e.g. echo "Foo.\nBar."; echo -e "Foo.\nBar."
echo -e "Duplicate files report for the path $1\n" > $REPORT_FILENAME
echo -e "Generated on $START_DATETIME UTC\n" >> $REPORT_FILENAME

# Use double quotes around $1 (find "$1"...) to protect against any spaces in the path in $1
# 2016/12/12 : Changed "sort -k1,32" to "sort"
find "$1" -type f -print0 | xargs --null md5sum | sort | uniq -D -w 32 >> $REPORT_FILENAME

# See https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another

# The function "pipe_status" is defined in bash_script_include.sh ;
# Functions that are defined in .bashrc are not visible in this script -> Find out why not.
EXITCODE=$(pipe_status)

echo "Done."
echo "Started on $START_DATETIME"
echo "Ended on   $(date_time_utc)"

[ $EXITCODE -eq 0 ] && {
	echo "Success!"
} || {
	echo "Error; exit code $EXITCODE."
}

clean_up $EXITCODE
