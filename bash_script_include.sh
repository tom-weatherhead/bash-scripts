# bash_script_include.sh

# PROGRAM_NAME=$(basename "$0")
PROGRAM_NAME=$(basename "$0" 2>/dev/null)

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
	echo_error_message "Cleaning up: Exiting with status $1."
	exit $1
}

# This trap command works on bash, but on Ubuntu 16.10, dash (via sh) complains: "trap: SIGHUP: bad trap" ; another reason to use #!/bin/bash instead of #!/bin/sh ?
# See e.g. https://lists.yoctoproject.org/pipermail/yocto/2013-April/013125.html
trap clean_up SIGHUP SIGINT SIGTERM

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

check_directory_exists_and_is_readable()
{
	if ! [ -e "$1" ]; then # We need to use "$1" instead of $1 , in case $1 contains whitespace.
		error_exit "$1 does not exist."
	elif ! [ -d "$1" ]; then
		error_exit "$1 is not a directory."
	elif ! [ -r "$1" ]; then
		error_exit "$1 is not readable by the current user."
	fi
}

check_directory_is_writable_if_it_exists()
{
	if [ -e "$1" ]; then
		if ! [ -d "$1" ]; then
			error_exit "$1 is not a directory."
		elif ! [ -w "$1" ]; then
			error_exit "$1 is not writable by the current user."
		fi
	fi
}

check_directory_exists_and_is_writable()
{
	[ -e "$1" ] || { # We need to use "$1" instead of $1 , in case $1 contains whitespace.
		error_exit "$1 does not exist."
	} && [ -d "$1" ] || {
		error_exit "$1 is not a directory."
	} && [ -w "$1" ] || {
		error_exit "$1 is not writable by the current user."
	}
	
	# The above structure works, but something like this:
	
	# [ test1 ] && {
	#    command1
	# } || else [test2] && {
	#    command2
	# ...
	# }
	
	# ... can result in all of the commands being run...
	# due to the relative precedence of the && and || operators?
}

check_directory()
{
	check_directory_exists_and_is_writable "$1"
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

# Determine which Linux or Linux-like distribution is running on the system.

determine_distro()
{
	# Find the Distributor ID:
	if [ "$(uname -o)" == "Cygwin" ]; then
		echo 'Cygwin'
	elif grep -q Microsoft /proc/version; then # WSL; See https://stackoverflow.com/questions/38859145/detect-ubuntu-on-windows-vs-native-ubuntu-from-bash-script
		echo "Ubuntu on Windows" # This string delibrately starts with Ubuntu, so that both WSL and genuine Ubuntu return results that match the regex /^Ubuntu/
	elif which lsb_release 1>/dev/null 2>&1; then
		lsb_release -is
	elif [ -e /etc/os-release ]; then
		cat /etc/os-release | perl -nle 'print $1 if /^NAME="?(.*?)"?$/'
	else
		echo "Unknown distribution"
	fi
}

# distro_is_* usage: E.g. : if [ "$(distro_is_linux)" ]; then echo "Y"; else echo "N"; fi

distro_is_cygwin()
{
	# if [ "$(uname -o)" == "Cygwin" ]; then
	if [ "$(determine_distro)" == "Cygwin" ]; then
		echo 1
	else
		echo
	fi
}

distro_is_linux()
{
	if [ "$(uname -o)" == "GNU/Linux" ]; then
		echo 1
	else
		echo
	fi
}

print_linux_distro_name()
{
	cat /etc/*-release 2>/dev/null | perl -nle 'print $1 if /^DISTRIB_ID=(.*)$/'
}

# distro_is_debian() {}

distro_is_ubuntu() # Some form of Ubuntu; possibly WSL.
{
	# if [ "$(print_linux_distro_name)" == "Ubuntu" ]; then
	if [[ "$(determine_distro)" =~ ^Ubuntu ]]; then
		echo 1
	else
		echo
	fi
}

distro_is_wsl() # WSL == Windows 10 Subsystem for Linux; a variant of Ubuntu
{
	if [[ "$(determine_distro)" =~ ^Ubuntu[[:space:]] ]]; then
		echo 1
	else
		echo
	fi
}

distro_is_ubuntu_not_wsl()
{
	if [ "$(determine_distro)" == 'Ubuntu' ]; then
		echo 1
	else
		echo
	fi
}

distro_is_fedora()
{
	if [ "$(determine_distro)" == 'Fedora' ]; then
		echo 1
	else
		echo
	fi
}

# distro_is_centos() {}

# distro_is_red_hat_family() {}

get_windows_drive_mounts_path()
{
	case $(determine_distro) in
		"Cygwin")
			echo "/cygdrive"
			;;

		"Ubuntu on Windows")
			echo "/mnt"
			;;

		*)
			echo
			# Test the return of this function with [ -z ... ] ?
			# Or: error_exit "No Windows drives on this distro: $OPTARG"
			# No ;; is necessary for the last case.
	esac
}

get_null_device_name()
{
    if [ $(determine_distro) == 'Cygwin' ]; then
        echo 'NUL'
    elif [ -e /dev/null ]; then
        echo '/dev/null'
    else
        error_exit 'Unable to determine the null device for this system'
    fi
}

which_test_quiet()
{
	which $1 1>/dev/null 2>&1 && echo 1 || echo
}

safe_eval()
{
	CMD=$(echo $1 | awk '{print $1}')
	
	# if which $CMD >/dev/null 2>&1; then
		# eval $1
	# fi
	which_test_quiet $CMD && eval $1
}

# safe_eval "$1" # For testing.

is_a_non_negative_integer()
{
	[[ "$1" =~ ^[0-9]+$ ]] && echo 1 || echo
}

# [ $(is_a_non_negative_integer 128) ] && echo "128 is a non neg int!" || echo "128 is NOT a non neg int."
# [ $(is_a_non_negative_integer "128") ] && echo "128 is a non neg int!" || echo "128 is NOT a non neg int."
# [ $(is_a_non_negative_integer "abc.mp3") ] && echo "abc.mp3 is a non neg int!" || echo "abc.mp3 is NOT a non neg int."
# [ $(is_a_non_negative_integer) ] && echo "(empty) is a non neg int!" || echo "(empty) is NOT a non neg int."

# ***

# SOURCE_FILE_PATH="$1"
# SOURCE_FILENAME_WITH_EXTENSION=$(basename "$SOURCE_FILE_PATH")
# SOURCE_EXTENSION="${SOURCE_FILENAME_WITH_EXTENSION##*.}" # If SOURCE_FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of SOURCE_FILENAME_WITH_EXTENSION

# Is this SOURCE_FILENAME_BASE or is it all of SOURCE_FILE_PATH minus the extension? -> The former: Just the filename base. E.g. If SOURCE_FILE_PATH is /dir1/dir2/dir3/filename.ext, then SOURCE_FILENAME_BASE is just "filename".
# SOURCE_FILENAME_BASE=$(basename -s ."$SOURCE_EXTENSION" "$SOURCE_FILE_PATH")

# End of bash_script_include.sh
