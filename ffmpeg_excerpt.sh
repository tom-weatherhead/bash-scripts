#!/bin/bash

PROGRAM_NAME=$(basename "$0")

usage()
{
	# Output the usage message to the standard error stream.
	echo 1>&2
	echo "Usage: $PROGRAM_NAME -s StartTime -t EndTime InputFilename" 1>&2
	echo 1>&2
	echo "E.g. $PROGRAM_NAME -s 13:37 -t 1:06:23 foo/bar/video.mp4" 1>&2
	echo 1>&2
}

clean_up()
{
	# Perform end-of-execution housekeeping
	# Optionally accepts an exit status
	# TEMP_FILES="ffmpeg2pass-*.log*"
	# rm -f $TEMP_FILES
	# rm -f ffmpeg2pass-*.log*
	exit $1
}

error_exit()
{
	# Display an error message and exit
	echo "${PROGRAM_NAME}: ${1:-"Unknown Error"}" 1>&2
	clean_up 1
}

where_test()
{
	where $1 > /dev/null 2>&1 && {
		echo "Command '$1' found."
	} || {
		error_exit "Command '$1' not found; exiting."
	}
}

trap clean_up SIGHUP SIGINT SIGTERM

where_test ffmpeg

# Using getopts to detect and handle command-line options : See https://stackoverflow.com/questions/16483119/example-of-how-to-use-getopts-in-bash

parse_time()
{
	if [[ $1 =~ ^([0-9]{1,2}):([0-9]{2}):([0-9]{2})$ ]]; then
		echo ${BASH_REMATCH[1]}h${BASH_REMATCH[2]}m${BASH_REMATCH[3]}s
	elif [[ $1 =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
		echo ${BASH_REMATCH[1]}m${BASH_REMATCH[2]}s
	else
		echo "No regex match for $1"
		exit 1
	fi
}

START_TIME=""
END_TIME=""

# See https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/

# getopts can handle single-character options only.
# For longer options, use getopt : See https://linuxaria.com/howto/parse-options-in-your-bash-script-with-getopt

while getopts ":s:t:" option; do
    case $option in
        s)
			START_TIME_STRING=$(parse_time $OPTARG)
			START_TIME=$OPTARG
            ;;
        t)
			END_TIME_STRING=$(parse_time $OPTARG)
			END_TIME=$OPTARG
            ;;
		:)
            usage
			error_exit "Invalid option: $OPTARG requires an argument"
			;;
		*)
            usage
			error_exit "Unrecognized option: -$OPTARG"
            # No ;; is necessary here.
    esac
done
shift $((OPTIND -1))

#PARSED_OPTIONS=$( getopt -o "p:d:a:r:" -- "$@" )
#eval set -- "$PARSED_OPTIONS"
#while true; do
#    case $1 in
#        p) proxy=$2; shift 2 ;;
#        d) dir=$2; shift 2 ;;
#        a) ua=$2; shift 2 ;;
#        r) ref=$2; shift 2;;
#        --) shift; break ;;
#    esac
#done

if [ $# != 1 ]; then # Using != instead of -ne
	usage
	error_exit "Exactly one file to convert must be specified as a command-line argument."
elif [ -z "$START_TIME" ]; then
	usage
	error_exit "The start time (the -ss option) was not detected."
elif [ -z "$END_TIME" ]; then
	usage
	error_exit "The end time (the -to option) was not detected."
fi

# In order to handle spaces in $1, wrap it in quotes: "$1"

# Get file extension: see http://tecadmin.net/how-to-extract-filename-extension-in-shell-script/
FILENAME_WITH_EXTENSION=$(basename "$1")
EXTENSION="${FILENAME_WITH_EXTENSION##*.}" # If FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of FILENAME_WITH_EXTENSION

# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
FILENAME=$(basename -s ."$EXTENSION" "$1")

OUTPUT_FILENAME="${FILENAME}_${START_TIME_STRING}_${END_TIME_STRING}.$EXTENSION"

echo "ffmpeg -i $1 -ss $START_TIME -to $END_TIME -c copy $OUTPUT_FILENAME"

ffmpeg -i "$1" -ss $START_TIME -to $END_TIME -c copy "$OUTPUT_FILENAME"

EXIT_STATUS=$?

echo "Exit status: $EXIT_STATUS"

if [ $EXIT_STATUS != 0 ]; then
	echo "ffmpeg experienced an error.";
fi

clean_up $EXIT_STATUS