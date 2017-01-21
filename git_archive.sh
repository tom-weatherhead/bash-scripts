#!/bin/bash

# git-archive.sh - November 29, 2016
# Create encrypted and unencrypted archives of a local Git repository.

# source bash_script_includes.sh
# ... or:
# . bash_script_includes.sh

tar_bz2_writing_function()
{
	echo "git archive --format=tar -- HEAD | bzip2 -9 - > $1"
	git archive --format=tar HEAD | bzip2 -9 - > $1
}

tar_gpg_gpg_writing_function()
{
	echo "git archive --format=tar HEAD | gpg -r tomw3 -e | gpg -r tomw2 -e -o $1"
	git archive --format=tar HEAD | gpg -r tomw3 -e | gpg -r tomw2 -e -o $1
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
			# git archive --format=tar HEAD | bzip2 -9 - > $BZ2NAME
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

		# ADDENDUM="_$i"
		ADDENDUM=$(printf "_%03d" $i) # Use exactly three digits, with leading zeroes; e.g. 1 -> 001; 13 -> 013
	done

	echo $RESULT_OF_WRITE
}

if [ -d .git ]; then
	echo "A .git directory was found."
else
	echo "No .git directory was found; exiting."
	exit 1
fi

#ARCHIVEDIR="../../Archive" # If $# == 0 then ARCHIVEDIR="../../Archive" elif $# == 1 then ARCHIVEDIR="$1" else error fi
ARCHIVEDIR="/cygdrive/c/NoArchiv/GitArchiveTest"

if [ -d $ARCHIVEDIR ]; then
	echo "The Archive directory was found.";
else
	# Use error_exit
	echo "The Archive directory was not found; exiting.";
	exit 1
fi

echo

BASENAME="${ARCHIVEDIR}/$(basename $(pwd))$(date +%Y%m%d)"

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
echo
exit $RESULT_CODE
