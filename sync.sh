#!/bin/bash

# Use rsync to mirror a file system subtree.

# **** BEGIN --iconv ****
# Handle character set changes, e.g. when copying a path including 'Bela Bartok' (with accent(s))
# from a macOS filesystem to exFAT.

# See https://askubuntu.com/questions/533690/rsync-with-special-character-files-not-working-between-mac-and-linux

# Nick the Swede:

# The solution was embarrassingly simple: Much due to a comment I read when researching the problem,
# I thought you were supposed to specify the character set in the order of transformation; but it seems
# as that is not the correct syntax. Rather, one should always use --iconv=utf-8-mac,utf-8 when initialising
# the rsync from the mac, and always use --iconv=utf-8,utf-8-mac when initialising the rsync from the linux machine,
# no matter if I want to sync files from the mac or linux machine.

# Then it works like magic!

# EDIT: Indeed, sometimes, checking the manual page closely is a good thing to do. Here it is, black on white:

# --iconv=CONVERT_SPEC

# Rsync  can  convert  filenames between character sets using this
# option.  Using a CONVERT_SPEC of "." tells rsync to look up  the
# default  character-set via the locale setting.  Alternately, you
# can fully specify what conversion to do by giving a local and  a
# remote   charset   separated   by   a   comma   in   the   order
# --iconv=LOCAL,REMOTE, e.g.  --iconv=utf8,iso88591.   This  order
# ensures  that the option will stay the same whether you're push-
# ing  or  pulling  files.

# ThAW: So:

# if host is a Mac then --iconv=utf-8-mac,utf-8
# else if host is Linux then --iconv=utf-8,utf-8-mac
# else (e.g. if the host is Windows or Cygwin) then (--iconv=utf-8,utf-8-mac ? Test this.)

RSYNC_ICONV_OPTION_FROM_MAC='--iconv=utf-8-mac,utf-8'
RSYNC_ICONV_OPTION_TO_MAC='--iconv=utf-8,utf-8-mac'

if [ "$(uname -s)" == 'Darwin' ]; then
	RSYNC_ICONV_OPTION_FORWARD="$RSYNC_ICONV_OPTION_FROM_MAC" # Reverse the order of these values for files being deleted; e.g. when deleting files as part of a sync from a Mac to an exFAT volume.
	RSYNC_ICONV_OPTION_REVERSE="$RSYNC_ICONV_OPTION_TO_MAC"
else
	RSYNC_ICONV_OPTION_FORWARD="$RSYNC_ICONV_OPTION_TO_MAC"
	RSYNC_ICONV_OPTION_REVERSE="$RSYNC_ICONV_OPTION_FROM_MAC" # Use this when deleting files???
fi

# TODO: Which ICONV_OPTIONS should be used when syncing from Mac to Mac or from non-Mac to non-Mac?

# **** END --iconv ****

# See https://www.cyberciti.biz/faq/linux-unix-apple-osx-bsd-rsync-copy-hard-links/

# Exclude the system directories at the root of the drive:
# - $RECYCLE.BIN
# - $Recycle.Bin
# - "System Volume Information"

# rsync
# -a equals -rlptgoD (no -H, -A, -X); remove -g (preserve group), -o (preserve owner), and maybe -p (preserve permissions).
#   - -A, --acls = Preserve ACLs (access control lists) (implies -p)
#   - -D = Same as --devices --specials
#   - -E, --executability = Preserve executability
#   - -H, --hard-links = Preserve hard links
#   - -K, --keep-dirlinks = Treat symlinked dir on receiver as dir
#   - -P = Same as --partial --progress
#   - -W, --whole-file = Copy files whole (w/o delta-xfer algorithm)
#   - -X, --xattrs = Preserve extended attributes
#   - -a, --archive = Archive mode; equals -rlptgoD (no -H,-A,-X)
#   - -c, --checksum = Skip based on checksum, not mod-time & size
#   - -g, --group = Preserve group
#   - -h, --human-readable = Output numbers in a human-readable format
#   - -i, --itemize-changes = Output a change-summary for all updates
#   - -l, --links = Copy symlinks as symlinks
#	- -m, --prune-empty-dirs = Prune empty directory chains from file-list
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

# Ideas:
# -m, --prune-empty-dirs
# --exclude-from=FILE

###

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "$PROGRAM_NAME takes either one or two arguments; i.e.:"
	echo_error_message "$PROGRAM_NAME [-d] [-n] destination_drive_letter"
	echo_error_message "$PROGRAM_NAME [-d] [-n] /path/to/src/ /path/to/dest"
	echo_error_message '-d = Delete (during the transfer) files that are in the destination but not in the source'
	echo_error_message '-n = Perform a trial run with no changes made'
	echo_error_message
}

which_test rsync

RSYNC_DELETE_OPTION=''	# The delete option is turned off by default, for safety.
RSYNC_DRY_RUN_OPTION=''
RSYNC_ICONV_OPTION=''
RSYNC_SSH_OPTION=''

while getopts ':dIins' option; do
    case $option in
		d)
			# --del is a alias for --delete-during
			# Other rsync delete possibilities are:
			# --delete = Delete extraneous files from dest dirs
			# --delete-before = Receiver deletes before xfer, not during
			# --delete-during = Receiver deletes during the transfer
			# --delete-delay = Find deletions during, delete after
			# --delete-after = Receiver deletes after transfer, not during
			# --delete-excluded = Also delete excluded files from dest dirs
			RSYNC_DELETE_OPTION='--del'
			;;
		I)
			# --iconv option - reverse.
			# The --iconv option is available in rsync version 3. (macOS: $ brew install rsync)
			RSYNC_ICONV_OPTION="$RSYNC_ICONV_OPTION_REVERSE"
			;;
		i)
			# --iconv option - forward.
			RSYNC_ICONV_OPTION="$RSYNC_ICONV_OPTION_FORWARD"
			;;
        n)
			RSYNC_DRY_RUN_OPTION='n'
            ;;
        s)
			RSYNC_SSH_OPTION='-e ssh'
			;;
		*)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
done

# if [ "$(distro_is_cygwin)" ]; then
	# We want to avoid having unwanted entries (e.g. "NULL SID" or "Deny foo") added to the ACL on a Windows receiver; this problem occurs when this script is run within Cygwin, but it apparently does not occur under the Windows Subsystem for Linux.
	# But it is safe to use this script with Cygwin to rsync via ssh.
	# error_exit 'This script might not preserve Access Control Lists when run from Cygwin; aborting.'
# fi

# We rewrote the "distro_is_cygwin" function to use "return" rather than "echo" :
[ -z "RSYNC_SSH_OPTION" ] && distro_is_cygwin && error_exit 'This script might not preserve Access Control Lists when run from Cygwin; aborting.'

# echo 'Cygwin not detected; we may proceed.'

shift $((OPTIND -1))

case $# in
	1)

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

# The quotes around $SRC_PATH and $DEST_PATH are needed to properly handle spaces in those paths.
check_directory_exists_and_is_readable "$SRC_PATH"
check_directory_is_writable_if_it_exists "$DEST_PATH"	# The DEST_PATH does not need to pre-exist; rsync can create it.

# Windows NTFS: Ensure that the receiver dir (or its parent dir, if it does not yet exist) has the desired permissions, and that permission inheritance is enabled.
# - This is best done for a VeraCrypt drive by setting the desired owner and permissions for the root of the drive, and then letting the rest of the items on the drive inherit them.
# - The usual ACL for a VeraCrypt drive on Windows looks like this:
#	Type	Principal									Access			Inherited from		Applies to
#	Allow	SYSTEM										Full Control	None				This folder, subfolders, and files
#	Allow	Administrators (HOSTNAME\Administrators)	Full Control	None				This folder, subfolders, and files
#	Allow	Users (HOSTNAME\Users)						Read & execute	None				This folder, subfolders, and files
#	Allow	Authenticated Users							Modify			None				This folder, subfolders, and files
# - Note: The "Modify" permission includes Read and Execute.

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

# Note: In order to see a VeraCrypt-mounted NTFS drive under /mnt in Windows 10 Bash:
# 1) Configure VeraCrypt to *not* mount drives as removable media
# 2) Use VeraCrypt to mount the NTFS drive
# 3) Start up a Windows 10 Bash windows
# 4) ls -l /mnt
# 5) ls -l /mnt/x (replace x with the relevant drive letter); verify that you can see the drive's contents

# Don't use -a (the "archive" option) (: it doesn't preserve hard links : no -H)
# Should we use the -p option? (copy the source permissions to the destination)
# - The -p option seems to have no effect in WSL (Windows Subsystem for Linux) + NTFS
# RSYNC_SHORT_OPTIONS="-rltDH${RSYNC_DRY_RUN_OPTION}vz"
RSYNC_SHORT_OPTIONS="-rltD${RSYNC_DRY_RUN_OPTION}vz"

#   - -D = Same as --devices --specials
#   - -H, --hard-links = Preserve hard links
#   - -l, --links = Copy symlinks as symlinks
#   - -n, --dry-run = Perform a trial run with no changes made
#   - -r, --recursive = Recurse into directories
#   - -t, --times = Preserve modification times
#   - -v, --verbose = Increase verbosity
#   - -z, --compress = Compress file data during the transfer
#   - --devices = Preserve device files (super-user only)
#   - --numeric-ids = Don't map uid/gid values by user/group name
#   - --specials = Preserve special files

# We enable the --numeric-ids option below.
# The --numeric-ids option is necessary to preserve NTFS hard links.

# Let's exclude system folders that are found at the roots of drives,
# whether the OS is macOS, Windows, or Linux:

# - .fseventsd
# - .Spotlight-V100
# - .Trash-1000
# - .Trashes
# - $RECYCLE.BIN
# - System Volume Information

# If eval sees $RECYCLE.BIN , it interprets $RECYCLE as an evaluation of the variable RECYCLE.
# Can we suppress this part of eval's behaviour, or use something else instead of eval?
# How can we describe a literal dollar sign to eval?
# -> ? The dollar sign must be escaped with '$' : See https://unix.stackexchange.com/questions/23111/what-is-the-eval-command-in-bash
#   -> We also use Bash's printf %q to escape special characters in file paths for us

# ThAW 2017/03/11 : I have not yet found a way to make an rsync exclude pattern case-insensitive other that the ugly [Rr][Ee][Cc][Yy][Cc][Ll][Ee]
RSYNC_EXCLUDE_OPTIONS="--exclude '?'[Rr][Ee][Cc][Yy][Cc][Ll][Ee].[Bb][Ii][Nn] --exclude 'System Volume Information' --exclude '~*' --exclude '._*' --exclude '.DS_Store' --exclude 'Thumbs.db' --exclude '.fseventsd' --exclude '.Spotlight-V100' --exclude '.TemporaryItems' --exclude '.Trash-1000' --exclude '.Trashes' --exclude 'Stuff'"

[[ $SRC_PATH =~ Music || $DEST_PATH =~ iTunes ]] && {
	echo 'DEST_PATH backup: Not backing up Home Videos, etc. ...'
	# .m4r files are ringtones; they are essentially renamed .m4a files
	# .m4v files are videos
	RSYNC_EXCLUDE_OPTIONS="$RSYNC_EXCLUDE_OPTIONS --exclude '*.m4r' --exclude '*.m4v' --exclude 'Audiobooks' --exclude 'Automatically Add to Music.localized' --exclude 'Automatically Add to TV.localized' --exclude 'Books' --exclude 'Downloads' --exclude 'Home Videos' --exclude 'Mobile Applications' --exclude 'Podcasts'"
}

# Use Occam's Razor to eliminate any unnecessary options.

# RSYNC_LONG_OPTIONS="--chmod=ugo=rwX --chown=tomw:tomw $RSYNC_DELETE_OPTION $RSYNC_EXCLUDE_OPTIONS --numeric-ids"
RSYNC_LONG_OPTIONS="$RSYNC_DELETE_OPTION $RSYNC_EXCLUDE_OPTIONS $RSYNC_ICONV_OPTION --numeric-ids"

# See https://stackoverflow.com/questions/2854655/command-to-escape-a-string-in-bash
echo_and_eval $(printf "rsync $RSYNC_SHORT_OPTIONS $RSYNC_LONG_OPTIONS %q $RSYNC_SSH_OPTION %q" "$SRC_PATH" "$DEST_PATH")
# printf "rsync $RSYNC_SHORT_OPTIONS $RSYNC_LONG_OPTIONS %q $RSYNC_SSH_OPTION %q" "$SRC_PATH" "$DEST_PATH"

RSYNC_STATUS=$?
echo "rsync returned status code $RSYNC_STATUS"

case $RSYNC_STATUS in
	25)
		printf '%s\n' 'Deletion limit was reached.' # >"$logfile"
		;;
	# *)
		# No ;; is necessary here.
esac

# echo "--iconv=$ICONV_OPTIONS"

clean_up $RSYNC_STATUS

#### **** The End ****

# The following steps are probably not necessary, but users who like to practice applied paranoia may want to follow them to ensure that the file system ACLs on the receiver are sane and rational.

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

# rsync from local to remote or vice versa: See https://www.liquidweb.com/kb/how-to-securely-transfer-files-via-rsync-and-ssh-on-linux/

# Use These Commands to Securely Download From a Server

# Standard SSH Port:

# rsync -avHe ssh user@server:/path/to/file /home/user/path/to/file

    # user: The username of the remote user through which you’ll be logging into the target (remote) server.
    # server: The hostname or IP address of the target (remote) server.
    # /path/to/file: The path to the file that needs to be downloaded from the target (remote) server, where file is the file name.
    # /home/user/path/to/file: The local path where you would like to store the file that is downloaded from the target (remote) server, where file is the file name.

# Example:

# rsync -avHe ssh adam@web01.adamsserver.com:/home/adam/testfile1 /home/localuser/testfile1

# Use These Commands to Securely Upload To a Server

# Standard SSH Port:

# rsync -avH /home/user/path/to/file -e ssh user@server:/path/to/file

    # /home/user/path/to/file: The local path where the file that will be uploaded to the target (remote) server exists, where file is the file name.
    # user: The username of the remote user through which you’ll be logging into the target (remote) server.
    # server: The hostname or IP address of the target (remote) server.
    # /path/to/file: The remote path for the file that will be uploaded to the target (remote) server, where file is the file name.

# Example:

# rsync -avH /home/localuser/testfile1 -e ssh adam@web01.adamsserver.com:/home/adam/testfile1

### The End. ###
