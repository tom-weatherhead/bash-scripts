#!/bin/bash

# Using rsync to mirror a file system subtree.

# rsync
#   -a : Archive mode; equals -rlptgoD (no -H, -A, -X)
#   -c : Skip based on checksum, not mod-time & size
#   -E : Preserve executability
#   -h : Output numbers in a human-readable format
#   -H : Preserve hard links
#   -n : Perform a trial run with no changes made (dry run)
#   -p : Preserve permissions
#   -r : Recursive
#   -u : Skip files that are newer on the receiver
#   -v : Verbose
#   -W : Copy files whole (w/o delta-xfer algorithm)

# Examples from: man rsync

# rsync -t *.c foo:src/
# rsync -avz foo:src/bar /data/tmp
# rsync -avz foo:src/bar/ /data/tmp
# rsync -av /src/foo /dest
# rsync -av /src/foo/ /dest/foo
# rsync -av host: /dest
# rsync -av host::module /dest
# rsync somehost.mydomain.com::
# rsync -av host:file1 :file2 host:file{3,4} /dest/
# rsync -av host::modname/file{1,2} host::modname/file3 /dest/
# rsync -av host::modname/file1 ::modname/file{3,4}
# rsync -av host:'dir1/file1 dir2/file2' /dest
# rsync host::'modname/dir1/file1 modname/dir2/file2' /dest
# rsync -av host:'file\ name\ with\ spaces' /dest
# rsync -av host::src /dest
# rsync -av --rsh=ssh host:module /dest
# rsync -av -e "ssh -l ssh-user" rsync-user@host::module /dest
# rsync -Cavz . arvidsjaur:backup 
# Makefile tar-gets:
#	get:
#		rsync -avuzb --exclude '*~' samba:samba/ .
#	put:
#		rsync -Cavuzb . samba:samba/
#	sync: get put
#
# rsync -az -e ssh --delete ~ftp/pub/samba nimbus:"~ftp/pub/tridge"

###

# From https://sanctum.geek.nz/arabesque/testing-exit-values-bash/ :

# rsync --archive --delete --max-delete=5 source destination
# if (($? == 25)); then
#     printf '%s\n' 'Deletion limit was reached' >"$logfile"
# fi

###

# Ideas:
# --prune-empty-dirs
# --exclude=PATTERN
# --exclude-from=FILE

###

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
	echo_error_message "$PROGRAM_NAME takes either one or two arguments; i.e.:"
	echo_error_message "$PROGRAM_NAME [-n] destination_drive_letter"
	echo_error_message "$PROGRAM_NAME [-n] /path/to/src/ /path/to/dest"
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

check_directory()
{
	if ! [ -e "$1" ]; then # We need to use "$1" instead of $1 , in case $1 contains whitespace.
		error_exit "$1 does not exist."
	elif ! [ -d "$1" ]; then
		error_exit "$1 is not a directory."
	#elif ! [ -w "$1" ]; then
	#	error_exit "$1 is not writable by the current user."
	fi
}

trap clean_up SIGHUP SIGINT SIGTERM

which_test rsync

OPTION_N=""

while getopts ":n" option; do
    case $option in
        n)
			OPTION_N="n"
            ;;
		*)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
done

shift $((OPTIND -1))

case $# in
	1)
		# echo "1 via case"
		# echo "\$1 is $1"

		[[ $1 =~ ^[a-z]$ ]] || {
			error_exit "$1 is not a lowercase letter."
		}
		
		[[ $(pwd) =~ ^/([a-z]+)/([a-z]) ]] && {
			MOUNTS_DIR=${BASH_REMATCH[1]}
			SRC_PATH="/$MOUNTS_DIR/${BASH_REMATCH[2]}/"
			DEST_PATH="/$MOUNTS_DIR/$1"
		} || {
			error_exit "Failed to find the root directory of the current drive."
		}

		;;
	2)
		# echo "2 via case"
		# echo "\$1 is $1"
		# echo "\$2 is $2"

		# Use a regex to ensure that $SRC_PATH ends with a /

		[[ $1 =~ /$ ]] && {
			SRC_PATH=$1
		} || {
			SRC_PATH=$1/
		}

		DEST_PATH=$2
		;;
	*)
		error_exit "1 or 2 arguments expected; $# arguments received."
		# No ;; is necessary here.
esac

echo "SRC_PATH is $SRC_PATH"
echo "DEST_PATH is $DEST_PATH"

check_directory "$SRC_PATH"
#check_directory "$DEST_PATH"

# The general idea is: rsync -aHvz --delete-before --numeric-ids src/ dest
# See https://www.cyberciti.biz/faq/linux-unix-apple-osx-bsd-rsync-copy-hard-links/

# Exclude the system directories at the root of the drive:
# - $RECYCLE.BIN
# - "System Volume Information"

# The quotes around $SRC_PATH and $DEST_PATH are needed to properly handle spaces in those paths.
# Try --del or --delete in place of --delete-before :
# -a equals -rlptgoD (no -H,-A,-X); remove -g (preserve group), -o (preserve owner), and maybe -p (preserve permissions).
RSYNC_COMMAND="rsync -aH${OPTION_N}vz --del --exclude=?RECYCLE.BIN --exclude=System\ Volume\ Information --numeric-ids \"$SRC_PATH\" \"$DEST_PATH\""

echo $RSYNC_COMMAND
eval $RSYNC_COMMAND

RSYNC_STATUS=$?
echo "rsync returned status code $RSYNC_STATUS"

case $RSYNC_STATUS in
	25)
		printf '%s\n' 'Deletion limit was reached.' # >"$logfile"
		;;
	# *)
		# No ;; is necessary here.
esac

exit $RSYNC_STATUS
