#!/bin/bash

# Use find_duplicate_files.sh to find multiple copies of the same file(s), and then replace them with hard links (i.e. file system entities that appear as hard links, not shortcuts, in both NTFS and Ubuntu's file system).

# The essence of find_duplicate_files.sh is:

#	find "$1" -type f -print0 | xargs --null md5sum | sort | uniq -D -w 32

# Windows Command Prompt: Use mklink /H ; see https://jpsoft.com/help/mklink.htm

# https://superuser.com/questions/67870/what-is-the-difference-between-ntfs-hard-links-and-directory-junctions

# https://en.wikipedia.org/wiki/Hard_link

# https://unix.stackexchange.com/questions/3037/is-there-an-easy-way-to-replace-duplicate-files-with-hardlinks
# - http://cpansearch.perl.org/src/ANDK/Perl-Repository-APC-2.002/eg/trimtrees.pl
# - fdupes -r [-L] /path/to/folder : https://github.com/tobiasschulz/fdupes : Version 1.51-1 available in WSL (Ubuntu / Trusty)
# - rdfind [[-n|-dryrun] true] -makehardlinks true : Version 1.3.4-1ubuntu1 available in WSL (Ubuntu / Trusty)

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME [-n] path"
	echo_error_message
	echo_error_message "-n : Perform a dry run; do not make any changes"
	echo_error_message
	echo_error_message "E.g. $PROGRAM_NAME -n /path/to/directory"
	echo_error_message
}

which_test rdfind

DRY_RUN_OPTION=""

while getopts ":n" option; do
    case $option in
        n)
			DRY_RUN_OPTION="-dryrun true"
            ;;
		*)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
done
shift $((OPTIND -1))

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly one path must be specified as a command-line argument."
fi

rdfind $DRY_RUN_OPTION -makehardlinks true "$1"


# Bash's printf %q escapes the special characters in the file paths.
echo_and_eval $(printf "rdfind $DRY_RUN_OPTION -makehardlinks true %q" "$1")

EXIT_STATUS=$?

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "rdfind experienced an error."
fi

clean_up $EXIT_STATUS

# Notes:

# Duplicate Commander is software that allegedly solves this problem on the PC. See http://rayburnsoft.net/dc.html
# See also https://lifehacker.com/5808408/duplicate-commander-removes-duplicate-files-replaces-them-with-hard-links
