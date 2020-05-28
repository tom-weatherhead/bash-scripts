#!/bin/bash

# create_bash_script_links.sh

# TODO: "Include" code (especially functions) from script_template.sh via e.g. :
# . script_template.sh
# ... or:
# source script_template.sh

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
	echo_error_message "$PROGRAM_NAME: Error: ${1:-"Unknown Error"}; exiting."
	clean_up 1
}

which_test()
{
	which $1 1>/dev/null 2>&1 && {
		echo "Command '$1' found."
	} || {
		error_exit "Command '$1' not found"
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

echo_and_eval()
{
	echo $@
	eval $@
}

trap clean_up SIGHUP SIGINT SIGTERM

# which_test required_command_1
# which_test required_command_2
# which_test required_command_3

# shift $((OPTIND -1))

EXPECTED_NUMBER_OF_ARGUMENTS=0

if [ $# != $EXPECTED_NUMBER_OF_ARGUMENTS ]; then # Using != instead of -ne
	usage
	error_exit "$EXPECTED_NUMBER_OF_ARGUMENTS argument(s) was/were expected; $# argument(s) was/were received"
fi

# TODO: From .bashrc:
# run_script_if_it_exists "$HOME/bin/determine_distro_core.sh"

determine_distro()
{
	# Find the Distributor ID:
	if [ "$(uname -s)" == 'Darwin' ]; then
		echo 'macOS'
	elif [ "$(uname -o)" == 'Cygwin' ]; then
		echo 'Cygwin'
	elif grep -q Microsoft /proc/version; then # WSL; See https://stackoverflow.com/questions/38859145/detect-ubuntu-on-windows-vs-native-ubuntu-from-bash-script
		echo 'Ubuntu on Windows' # This string delibrately starts with Ubuntu, so that both WSL and genuine Ubuntu return results that match the regex /^Ubuntu/
	elif [ "$(uname -o)" == 'GNU/Linux' ]; then
		echo 'Linux'
	# elif which lsb_release 1>/dev/null 2>&1; then
		# lsb_release -is
	# elif [ -e /etc/os-release ]; then
		# cat /etc/os-release | perl -nle 'print $1 if /^NAME="?(.*?)"?$/'
	else
		echo 'Unknown distribution'
	fi
}

case $(determine_distro) in
	macOS)
		echo 'Detected macOS'
		# PREFIX_PATH_TO_GIT_REPO='/usr/local'
		FULL_PATH_TO_GIT_REPO='/usr/local/git/sandbox'
		;;
	Cygwin)
		echo 'Detected Cygwin'
		# PREFIX_PATH_TO_GIT_REPO='/cygdrive/c/Archive'
		FULL_PATH_TO_GIT_REPO='/cygdrive/c/git/sandbox'
		;;
	'Ubuntu on Windows')
		echo 'Detected Ubuntu on Windows'
		# PREFIX_PATH_TO_GIT_REPO='/mnt/c/Archive'
		FULL_PATH_TO_GIT_REPO='/mnt/c/git/sandbox'
		;;
	Linux)
		echo 'Detected GNU/Linux'
		# PREFIX_PATH_TO_GIT_REPO="/home/$(whoami)"
		# PREFIX_PATH_TO_GIT_REPO="/usr/local"
		FULL_PATH_TO_GIT_REPO='/usr/local/git/sandbox'
		;;
	*)
		error_exit "Undetected operating system type '$OPTARG'"
		# No ;; is necessary here.
esac

# FULL_PATH_TO_GIT_REPO="$PREFIX_PATH_TO_GIT_REPO/Git/GitHubSandbox/tom-weatherhead/bash-scripts"

echo "FULL_PATH_TO_GIT_REPO = $FULL_PATH_TO_GIT_REPO"
echo

# Use "find" to print the absolute paths of the matching files.
# See https://askubuntu.com/questions/444551/get-absolute-path-of-files-using-find-command

find "$(cd $FULL_PATH_TO_GIT_REPO; pwd)" -iname '*.sh' -print | while read -r script_path; do
	# Get file extension: see http://tecadmin.net/how-to-extract-filename-extension-in-shell-script/
	FILENAME_WITH_EXTENSION=$(basename "$script_path")
	EXTENSION="${FILENAME_WITH_EXTENSION##*.}" # If FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of FILENAME_WITH_EXTENSION

	# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
	FILENAME=$(basename -s ."$EXTENSION" "$script_path")

	! [ -f "$FILENAME_WITH_EXTENSION" ] && {
		THE_COMMAND="ln -sf $script_path"
		echo_and_eval $THE_COMMAND
	} || {
		echo "$FILENAME_WITH_EXTENSION already exists."
	}
	
	! [ -f "$FILENAME" ] && {
		THE_SECOND_COMMAND="ln -s $FILENAME_WITH_EXTENSION $FILENAME"
		echo_and_eval $THE_SECOND_COMMAND
	} || {
		echo "$FILENAME already exists."
	}

	echo
done

EXIT_STATUS=$?

echo "The command exited with the status $EXIT_STATUS."

if [ $EXIT_STATUS != 0 ]; then
	echo 'The exit status indicates an error.'
fi

clean_up $EXIT_STATUS
