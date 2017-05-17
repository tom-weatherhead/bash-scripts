#!/bin/bash

SOURCE_STRING="Foo Key: Value"

# Bash

[[ $SOURCE_STRING =~ Key:\ (.*)$ ]] && echo "Bash regex match: ${BASH_REMATCH[1]}"

# Awk

# See http://www.markhneedham.com/blog/2013/06/26/unixawk-extracting-substring-using-a-regular-expression-with-capture-groups/
echo "$SOURCE_STRING" | awk '{ match($0, /Key:\ (.*)$/, arr); if(arr[1] != "") { print "Awk regex match: ", arr[1] } }'

# Sed

# See https://stackoverflow.com/questions/2777579/how-to-output-only-captured-groups-with-sed
echo "$SOURCE_STRING" | sed -rn 's/^.*Key: (.*)$/Sed regex match: \1/p'
