#!/bin/sh

INPUT_FILE_PATH="$1"
INPUT_FILENAME_WITH_EXTENSION=$(basename "$INPUT_FILE_PATH")

INPUT_EXTENSION="${INPUT_FILENAME_WITH_EXTENSION##*.}" # If INPUT_FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of INPUT_FILENAME_WITH_EXTENSION

# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
# Is this INPUT_FILENAME_BASE or is it all of SOURCE_FILE_PATH minus the extension? -> The former: Just the filename base. E.g. If INPUT_FILE_PATH is /dir1/dir2/dir3/filename.ext, then INPUT_FILENAME_BASE is just "filename".
INPUT_FILENAME_BASE=$(basename -s ."$INPUT_EXTENSION" "$INPUT_FILE_PATH")
OUTPUT_FILENAME="$INPUT_FILENAME_BASE.clean.$INPUT_EXTENSION"

perl -00lpe "s/\A(.*)$//m" "$INPUT_FILE_PATH" | perl -00ne 'BEGIN { $i = 1; } print $i++, "\n", s/<br>/<br \/>/r unless /Shirt Team/' > "$OUTPUT_FILENAME"

# perl -00lpe "s/\A(.*)$//m" "$INPUT_FILE_PATH" | perl -00ne 'BEGIN { $i = 1; } print "${\($i++)}\n", s/<br>/<br \/>/r unless /Shirt Team/' > "$OUTPUT_FILENAME"
