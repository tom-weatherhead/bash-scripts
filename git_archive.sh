#!/bin/bash

# git-archive.sh - November 29, 2016
# Create encrypted and unencrypted archives of a local Git repository.

. bash_script_include.sh

tar_bz2_writing_function()
{
	echo_and_eval git archive --format=tar HEAD | bzip2 -9 - > $1
}

tar_gpg_gpg_writing_function()
{
	echo_and_eval git archive --format=tar HEAD | gpg -r tomw3 -e | gpg -r tomw2 -e -o $1
}

find_available_filename_and_write()
# Usage: find_available_filename_and_write BASENAME file_extension writing_function
# E.g. :
#   find_available_filename_and_write "../../Archive/Repo20170101" ".tar.bz2" tar_bz2_writing_function
#   find_available_filename_and_write "../../Archive/Repo20170101" ".tar.gpg.gpg" tar_gpg_gpg_writing_function
{
	BASENAME=$1
	FILE_EXTENSION=$2
	WRITING_FUNCTION=$3

	MAX_NUM_FILES_OF_SAME_ARCHIVE_AND_DATE=10

	RESULT_OF_WRITE=1
	i=0
	ADDENDUM=''

	while true; do
		ARCHIVE_PATH_NAME="${BASENAME}${ADDENDUM}${FILE_EXTENSION}"

		[ -f $ARCHIVE_PATH_NAME ] && {
			echo "$ARCHIVE_PATH_NAME already exists."
		} || {
			echo "Creating $ARCHIVE_PATH_NAME ..."
			echo "$WRITING_FUNCTION $ARCHIVE_PATH_NAME"
			$WRITING_FUNCTION $ARCHIVE_PATH_NAME
			RESULT_OF_WRITE=$?
			break
		}

		i=$((i + 1))

		if [ $i -ge $MAX_NUM_FILES_OF_SAME_ARCHIVE_AND_DATE ]; then # TODO: Use "-ge" or ">" ?
			echo "Too many $FILE_EXTENSION files already exist."
			break
		fi

		ADDENDUM=$(printf "_%03d" $i) # Use exactly three digits, with leading zeroes; e.g. 1 -> 001; 13 -> 013
	done

	echo $RESULT_OF_WRITE
}

# Alterntively: [ -d .git ] || error_exit "No .git directory was found."
if [ -d .git ]; then
	echo "A .git directory was found."
else
	error_exit "No .git directory was found."
fi

case $# in
	0)
		ARCHIVEDIR=".."
		;;
	1)
		ARCHIVEDIR="$1"
		;;
	*)
		error_exit "0 or 1 argument(s) expected; $# arguments received."
		# No ;; is necessary here because fallthrough is not a problem.
esac

check_directory_exists_and_is_writable "$ARCHIVEDIR"

echo "The Archive directory '$ARCHIVEDIR' exists and is writable by the current user '$(whoami)'."

BASENAME="${ARCHIVEDIR}/$(basename $(pwd))"
DATETIME="$(date --utc +%Y%m%d_%H%M%S)"

if [[ $BASENAME =~ [0-9]$ ]]; then
	BASENAME="${BASENAME}_$DATETIME"
else
	BASENAME="$BASENAME$DATETIME"
fi

find_available_filename_and_write $BASENAME ".tar.bz2" tar_bz2_writing_function
RESULT_BZ2=$?

find_available_filename_and_write $BASENAME ".tar.gpg.gpg" tar_gpg_gpg_writing_function
RESULT_GPG=$?

if [ $RESULT_BZ2 == 0 ] && [ $RESULT_GPG == 0 ]; then
	RESULT_MESSAGE="Success."
	RESULT_CODE=0
else
	RESULT_MESSAGE="Failure. Error codes: For .tar.bz2 = $RESULT_BZ2 ; for .tar.gpg.gpg = $RESULT_GPG."
	RESULT_CODE=1
fi

echo $RESULT_MESSAGE
clean_up $RESULT_CODE
