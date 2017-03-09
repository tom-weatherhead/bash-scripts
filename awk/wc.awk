#!/usr/bin/awk -f

# Print number of lines, words, and characters (like wc)

# From https://en.wikipedia.org/wiki/AWK

{
    w += NF
    c += length + 1
}

END { print NR, w, c }
