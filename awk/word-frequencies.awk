#!/usr/bin/awk -f

# Calculate word frequencies using associative arrays

# From https://en.wikipedia.org/wiki/AWK

BEGIN { FS="[^a-zA-Z]+" }

{
    for (i=1; i<=NF; i++)
        words[tolower($i)]++
}

END {
    for (i in words)
        print i, words[i]
}
