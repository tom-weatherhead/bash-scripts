#!/bin/bash

# Change all .mov and .MOV file extensions in the current directory to .mp4

. bash_script_include.sh

usage()
{
	# Output the usage message to the standard error stream.
	echo_error_message
	echo_error_message "Usage: $PROGRAM_NAME [-n]"
	echo_error_message "-n : Dry run; make no changes, but describe the changes that would be made"
	echo_error_message
}

# From https://stackoverflow.com/questions/10523415/bash-script-to-execute-command-on-all-files-in-a-directory :

# TODO: Detect the "dry run" option (-n)
DRY_RUN=

while getopts "n" option; do
    case $option in
        n)
			DRY_RUN=1
            ;;
        *)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
done

shift $((OPTIND -1))

if [ $# != 0 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly zero arguments must be provided as command-line arguments; $# arguments were provided."
fi

if [ -z $DRY_RUN ]; then
	echo "Dry run option NOT detected."
else
	echo "Dry run option detected!"
fi

# [ -z $DRY_RUN ] && echo "N" || echo "Y!"
# [ ! -z $DRY_RUN ] && echo "YY!!" || echo "NN"

change_file_extension_to_mp4()
{
	SOURCE_FILE_PATH="$1"

	# Get file extension: see http://tecadmin.net/how-to-extract-filename-extension-in-shell-script/
	SOURCE_FILENAME_WITH_EXTENSION=$(basename "$SOURCE_FILE_PATH")

	SOURCE_EXTENSION="${SOURCE_FILENAME_WITH_EXTENSION##*.}" # If SOURCE_FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of SOURCE_FILENAME_WITH_EXTENSION

	# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
	# Is this SOURCE_FILENAME_BASE or is it all of SOURCE_FILE_PATH minus the extension? -> The former: Just the filename base. E.g. If SOURCE_FILE_PATH is /dir1/dir2/dir3/filename.ext, then SOURCE_FILENAME_BASE is just "filename".
	SOURCE_FILENAME_BASE=$(basename -s ."$SOURCE_EXTENSION" "$SOURCE_FILE_PATH")
	
	DEST_FILENAME="$SOURCE_FILENAME_BASE.mp4"
	
	MV_COMMAND=$(printf "mv %q %q" "$SOURCE_FILE_PATH" "$DEST_FILENAME")
	
	# echo_and_eval()
	echo "$MV_COMMAND"
	[ -z $DRY_RUN ] && eval "$MV_COMMAND"
}

shopt -s nullglob		# See Comment 1 below.

# for file in /dir/*
# for file in ./*.mov
# do
	# cmd [option] "$file" >> results.out
	# echo "$file"
	# change_file_extension_to_mp4 "$file"
# done

for file in *.mov; do change_file_extension_to_mp4 "$file"; done

# for file in ./*.MOV
# do
	# change_file_extension_to_mp4 "$file"
# done

for file in *.MOV; do change_file_extension_to_mp4 "$file"; done

shopt -u nullglob # Revert nullglob. See Comment 1 below.

# Example

# el@defiant ~/foo $ touch foo.txt bar.txt baz.txt
# el@defiant ~/foo $ for i in *.txt; do echo "hello $i"; done
# hello bar.txt
# hello baz.txt
# hello foo.txt

# Comment 1:
# If no files exist in /dir/, then the loop still runs once with a value of '*' for $file, which may be undesirable. To avoid this, enable nullglob for the duration of the loop. Add this line before the loop shopt -s nullglob and this line after the loop shopt -u nullglob #revert nullglob back to it's normal default state. – Stew-au Sep 19 '12 at 7:38
	
# Comment 2:
# +1, And it just cost me my whole wallpaper collection. everyone after me, use doublequotes. "$file" – Behrooz Sep 12 '13 at 21:53
