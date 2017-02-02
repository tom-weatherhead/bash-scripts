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
# --del is a alias for --delete-during

# -a equals -rlptgoD (no -H,-A,-X); remove -g (preserve group), -o (preserve owner), and maybe -p (preserve permissions).
#   - -A, --acls = Preserve ACLs (access control lists) (implies -p)
#   - -D = Same as --devices --specials
#   - -E, --executability = Preserve executability
#   - -H, --hard-links = Preserve hard links
#   - -K, --keep-dirlinks = Treat symlinked dir on receiver as dir
#   - -P = Same as --partial --progress
#   - -X, --xattrs = Preserve extended attributes
#   - -a, --archive = Archive mode; equals -rlptgoD (no -H,-A,-X)
#   - -g, --group = Preserve group
#   - -h, --human-readable = Output numbers in a human-readable format
#   - -i, --itemize-changes = Output a change-summary for all updates
#   - -l, --links = Copy symlinks as symlinks
#   - -n, --dry-run = Perform a trial run with no changes made
#   - -o, --owner = Preserve owner
#   - -p, --perms = Preserve permissions
#   - -r, --recursive = Recurse into directories
#   - -t, --times = Preserve modification times
#   - -u, --update = Skip files that are newer on the receiver
#   - -v, --verbose = Increase verbosity
#   - -z, --compress = Compress file data during the transfer
#   - --chown=USER:GROUP = Simple username/groupname mapping
#   - --devices = Preserve device files (super-user only)
#   - --groupmap=STRING = Custom groupname mapping
#   - --numeric-ids = Don't map uid/gid values by user/group name
#   - --partial = Keep partially transferred files
#   - --partial-dir=DIR = Put a partially gtransferred file into DIR
#   - --progress = Show progress during transfer
#   - --specials = Preserve special files
#   - --usermap=STRING = Custom username mapping
#   - -- = 
#   - - = 

# TW 2017/01/24 : We want to avoid having unwanted entries (e.g. "NULL SID" or "Deny foo") added to the ACL on a Windows receiver. It seems to be problematic at least when the owner names are different on the source and receiver (e.g. tomw vs. tom_w).

# Windows NTFS: Ensure that the receiver dir (or its parent dir, if it does not yet exist) has the desired permissions, and that permission inheritance is enabled.
# - This is best done for a VeraCrypt drive by setting the desired owner and permissions for the root of the drive, and then letting the rest of the items on the drive inherit them.
# - The usual ACL for a VeraCrypt drive on Windows looks like this:
#	Type	Principal									Access			Inherited from		Applies to		
#	Allow	SYSTEM										Full Control	None				This folder, subfolders, and files
#	Allow	Administrators (HOSTNAME\Administrators)	Full Control	None				This folder, subfolders, and files
#	Allow	Users (HOSTNAME\Users)						Read & execute	None				This folder, subfolders, and files
#	Allow	Authenticated Users							Modify			None				This folder, subfolders, and files
# - Note: The "Modify" permission includes Read and Execute.

# TW 2017/01/24 : E.g.
# rsync -rltDHvz --chmod=ugo=rwX --chown=tomw:tomw --del --numeric-ids /mnt/x/Scripts/ /mnt/c/NoArchiv/ScriptsX

# See https://superuser.com/questions/69620/rsync-file-permissions-on-windows
# avguchenko's answer:
# (from http://www.samba.org/ftp/rsync/rsync.html)
#
# In summary: to give destination files (both old and new) the source permissions, use --perms.
#
# To give new files the destination-default permissions (while leaving existing files unchanged), make sure that the --perms option is off and use --chmod=ugo=rwX (which ensures that all non-masked bits get enabled).
#
# If you'd care to make this latter behavior easier to type, you could define a popt alias for it, such as putting this line in the file ~/.popt (the following defines the -Z option, and includes --no-g to use the default group of the destination dir):
#
#    rsync alias -Z --no-p --no-g --chmod=ugo=rwX

# The following Cygwin example won't work because it doesn't set up the ACL(s) (access control list(s)) on the receiver correctly:
# rsync -rltDHvz --chmod=ugo=rwX --chown=tomw:tomw --del --numeric-ids /cygdrive/j/Archive/TarBz2/ /cygdrive/c/NoArchiv/TarBz2

# Note: In order to see a VeraCrypt-mounted NTFS drive under /mnt in Windows 10 Bash:
# 1) Configure VeraCrypt to *not* mount drives as removable media
# 2) Use VeraCrypt to mount the NTFS drive
# 3) Start up a Windows 10 Bash windows
# 4) ls -l /mnt
# 5) ls -l /mnt/x (replace x with the relevant drive letter); verify that you can see the drive's contents

#2017/01/25 : E.g. :
# rsync -rltDHvz --chmod=ugo=rwX --chown=tomw:tomw --del --numeric-ids /mnt/y/Scripts/ /mnt/c/NoArchiv/ScriptsX
# rsync -rltDHvz --chmod=ugo=rwX --del --numeric-ids /mnt/y/Scripts/ /mnt/c/NoArchiv/ScriptsX
# 
 
#RSYNC_SHORT_OPTIONS="-aH${OPTION_N}vz"
#RSYNC_SHORT_OPTIONS="-rlptgoDH${OPTION_N}vz" # = "-aH${OPTION_N}vz" because -a = -rlptgoD
RSYNC_SHORT_OPTIONS="-rltDH${OPTION_N}vz"

RSYNC_DELETE_OPTION="--del" # --del is a alias for --delete-during

# RSYNC_LONG_OPTIONS="--chmod=ugo=rwX --chown=tomw:tomw $RSYNC_DELETE_OPTION --exclude=?RECYCLE.BIN --exclude=System\ Volume\ Information --numeric-ids"
# RSYNC_LONG_OPTIONS="--chmod=ugo=rwX $RSYNC_DELETE_OPTION --exclude=\$RECYCLE.BIN --exclude=System\ Volume\ Information --numeric-ids" # This does not exclude the recycle bin: \$ vs. ?
RSYNC_LONG_OPTIONS="--chmod=ugo=rwX $RSYNC_DELETE_OPTION --exclude=?RECYCLE.BIN --exclude=System\ Volume\ Information --numeric-ids" # The "?" is a wildcard that matches any one character.

RSYNC_COMMAND="rsync $RSYNC_SHORT_OPTIONS $RSYNC_LONG_OPTIONS \"$SRC_PATH\" \"$DEST_PATH\""

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

# On Windows: After this script completes successfully:
# 1) Right-click on the root directory of the receiver
# 2) Go to: Properties -> Security -> Advanced
# 3) Ensure that the owner is set correctly (e.g. to buddy.guy@hotmail.com). If you change the owner, propagate the change of ownership to all child objects, then click OK on both dialogs, and go back to step 1.
# 4) Ensure the ACL (the Access Control List) for this root directory look like this (substitute the correct hostname):

#	Type	Principal									Access			Inherited from		Applies to		
#	Allow	SYSTEM										Full Control	None				This folder, subfolders, and files
#	Allow	Administrators (HOSTNAME\Administrators)	Full Control	None				This folder, subfolders, and files
#	Allow	Users (HOSTNAME\Users)						Read & execute	None				This folder, subfolders, and files
#	Allow	Authenticated Users							Modify			None				This folder, subfolders, and files
# - Note: The "Modify" permission includes Read and Execute.

# 5) Check the box "Replace all child object permission entries with inheritable permission entries from this object"
# 6) Click on the "Apply" button, and let the permissions propagate
# 7) Click "OK"
# 8) Click "OK" again
