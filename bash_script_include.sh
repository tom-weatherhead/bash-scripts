# bash_script_include.sh

PROGRAM_NAME=$(basename "$0")

echo_error_message()
{
	# 1>&2 or 2>&1 ? -> 2>&1 !
	# https://www.google.ca/search?q=linux+1%3E%262+vs+2%3E%261
	# https://superuser.com/questions/436586/why-redirect-output-to-21-and-12

	echo $1 2>&1
}

#usage()
#{
#	# Output the usage message to the standard error stream.
#	echo_error_message
#	echo_error_message "This is the usage message for $PROGRAM_NAME ."
#	echo_error_message
#}

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
		# TODO? : Also ensure tha $1 is executable by the current user?
	} || {
		echo_error_message
		echo_error_message "The command '$1' was not found in the path."
		echo_error_message "To view the path, execute this command: echo \$PATH"
		echo_error_message
		error_exit "Command '$1' not found; exiting."
	}
}

echo_option_info()
{
	[ -z $2 ] && {
		echo "Option -$1 detected with no value."
	} || {
		echo "Option -$1 detected with value '$2'."
	}
}

check_directory()
{
	[ -e "$1" ] || { # We need to use "$1" instead of $1 , in case $1 contains whitespace.
		error_exit "$1 does not exist."
	} && [ -d "$1" ] || {
		error_exit "$1 is not a directory."
	} && [ -w "$1" ] || {
		error_exit "$1 is not writable by the current user."
	}
	
	# The above structure works, but somthing like this:
	
	# [ test1 ] && {
	#    command1
	# } || else [test2] && {
	#    command2
	# ...
	# }
	
	# ... can result in all of the commandN's being run...
	# due to the relative precedence of the && and || operators?
}

echo_and_eval()
{
	echo $@
	eval $@
}

get_windows_drive_mounts_path()
{
	case $(uname -o) in
		Cygwin)
			echo "/cygdrive"
			;;
		GNU/Linux)
			echo "/mnt"
			;;
		*)
			error_exit "Undetected operating system type '$OPTARG'"
			# No ;; is necessary here.
	esac
}

date_time_utc()
{
	echo "$(date --utc +'%F at %H:%M:%S') UTC"
}

pipe_status()
{
	# See https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another
	echo "${PIPESTATUS[@]}" | tr -s ' ' + | bc
}

# This trap command works on bash, but on Ubuntu 16.10, dash (via sh) complains: "trap: SIGHUP: bad trap" ; another reason to use #!/bin/bash instead of #!/bin/sh ?
# See e.g. https://lists.yoctoproject.org/pipermail/yocto/2013-April/013125.html
trap clean_up SIGHUP SIGINT SIGTERM

# End of bash_script_include.sh
