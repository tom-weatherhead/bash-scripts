#!/bin/bash

# find_duplicate_files.sh - Find all duplicate files in a subtree of the file system - November 18, 2016

PROGRAM_NAME=$(basename "$0")

usage()
{
	# Output the usage message to the standard error stream.
	echo
	echo "Usage: $PROGRAM_NAME path_to_root_of_subtree" 1>&2
	echo
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
	echo "${PROGRAM_NAME}: ${1:-"Unknown Error"}" 1>&2
	clean_up 1
}

# To send the signal "sig" to the process with PID "pid", run: kill -sig pid (e.g. kill -9 1234)

# PIDs (process IDs) can be found by running ps ; e.g. ps aux | grep firefox

# From https://www.tutorialspoint.com/unix/unix-signals-traps.htm :

# SIGHUP   1 Hang up detected on controlling terminal or death of controlling process
# SIGINT   2 Issued if the user sends an interrupt signal (Ctrl + C).
# SIGTERM 15 Software termination signal (sent by kill by default).

# Note: SIGKILL (signal 9) cannot be trapped.

# This trap command works on bash, but on Ubuntu 16.10, dash (via sh) complains: "trap: SIGHUP: bad trap" ; another reason to use #!/bin/bash instead of #!/bin/sh ?
# See e.g. https://lists.yoctoproject.org/pipermail/yocto/2013-April/013125.html
trap clean_up SIGHUP SIGINT SIGTERM

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly one path must be specified as a command-line argument."
fi

EXITCODE=0
START_DATETIME=$(date --utc +'%F %H:%M:%S')

# Use double quotes around $1 (find "$1"...) to protect against any spaces in the path in $1
find "$1" -type f -print0 | xargs --null md5sum | sort -k1,32 | uniq -D -w 32 > UniqReport$(date +%Y%m%d_%H%M%S).txt

# See https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another

if [ `echo "${PIPESTATUS[@]}" | tr -s ' ' + | bc` -ne 0 ]; then EXITCODE=1; echo "Error."; fi

echo "Done"
echo "Started at $START_DATETIME"
echo "Ended at   $(date --utc +'%F %H:%M:%S')"
echo "Exit code: $EXITCODE"
clean_up $EXITCODE