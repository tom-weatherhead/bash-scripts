#!/bin/bash

# Windows shortcut:
# Name: remote_hostname remote_command
# Target: C:\Path\To\Cygwin\Root\bin\bash.exe -lc "exec /home/username/bin/CygwinXRemoteCommand.sh remote_hostname remote_command"
# Start in: C:\Path\To\Cygwin\Root\bin

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME [-u remote_user] remote_hostname remote_command"
	echo_error_message
	echo_error_message "Examples:"
	echo_error_message "$PROGRAM_NAME Caritas firefox"
	echo_error_message "$PROGRAM_NAME Caritas lxterminal"
	echo_error_message
}

which_test ssh
				
# Using getopts to detect and handle command-line options : See https://stackoverflow.com/questions/16483119/example-of-how-to-use-getopts-in-bash

REMOTE_USER=$(whoami)

if [ "$REMOTE_USER" == 'tom_w' ]; then
	REMOTE_USER='tomw'
fi

while getopts "u:" option; do
	# echo "Option $option detected."
    case $option in
		u)
			# TODO: Verify that $OPTARG is a positive integer no greater than the system's number of CPU cores?
			# NUM_CPU_CORES=$(grep -c processor /proc/cpuinfo)
			REMOTE_USER=$OPTARG
			# echo "Number of pools is now $POOLS"
			;;
        *)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
done

shift $((OPTIND -1))

if [ $# != 2 ]; then # Using != instead of -ne
	usage
	error_exit "$# arguments detected; expected exactly two arguments."
fi

REMOTE_HOSTNAME="$1"
REMOTE_COMMAND="$2"

echo "Remote user is '$REMOTE_USER'."

if [ "$REMOTE_HOSTNAME" != 'Caritas' ]; then
	error_exit "Unexpected remote host '$REMOTE_HOSTNAME'."
fi

echo "Remote hostname '$REMOTE_HOSTNAME' accepted."

if [ "$REMOTE_COMMAND" != 'firefox' ] && [ "$REMOTE_COMMAND" != 'lxterminal' ]; then
	error_exit "Remote host '$REMOTE_HOSTNAME': Unexpected remote command '$REMOTE_COMMAND'."
fi

echo "Remote command '$REMOTE_COMMAND' accepted."

DISTRO_IS_CYGWIN=distro_is_cygwin

if $DISTRO_IS_CYGWIN; then
	# For Cygwin:
	SSH_OPTIONS='-Y'

	if ! ps aux | grep -q xwin ; then
		startxwin &
		sleep 6
		# Or wait until xwin is up and running:
		# while ! ps aux | grep -q xwin ; do
			# sleep 1
		# done
	fi
else
	SSH_OPTIONS='-X'
fi

# On Cygwin, use ssh -Y
# On real *nix, use ssh -X
echo_and_eval $(printf "ssh %s %s@%s %q 2>&1" "$SSH_OPTIONS" "$REMOTE_USER" "$REMOTE_HOSTNAME" "$REMOTE_COMMAND")

# killall xwin
# ... or:
# pskill xwin
