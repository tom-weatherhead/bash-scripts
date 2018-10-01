#!/usr/bin/env bash

# From https://stackoverflow.com/questions/26765163/delete-all-files-except-the-newest-3-in-bash-script :

# lesmana :

# This will list all files except the newest three:

# ls -t | tail -n +4

# This will delete those files:

# ls -t | tail -n +4 | xargs rm --

# This will also list dotfiles:

# ls -At | tail -n +4

# and delete with dotfiles:

# ls -At | tail -n +4 | xargs rm --
echo "ls -At | tail -n +4 | xargs rm --"

# Crontab for running a cron job every 5 minutes:
# */5 * * * * /path/to/script.sh

# But beware: parsing ls can be dangerous when the filenames contain funny characters like newlines or spaces. If you are certain that your filenames do not contain funny characters then parsing ls is quite safe, even more so if it is a one time only script.

# If you are developing a script for repeated use then you should most certainly not parse the output of ls and use the methods described here: http://mywiki.wooledge.org/ParsingLs

# flohall : 

# This is a combination of ceving's and anubhava's answer. Both solutions are not working for me. Because I was looking for a script that should run every day for backing up files in an archive, I wanted to avoid problems with ls (someone could have saved some funny name file in my backup saving folder). So I modified the mentioned solutions to fit my needs. Ceving's soltution deletes the three newest files - not what I needed and was asked.

# My solution deletes all files, except the three newest files.

# find . -type f -printf '%T@\t%p\n' |
# sort -t $'\t' -g | 
# head -n -3 | 
# cut -d $'\t' -f 2- |
# xargs rm
echo "or..."
echo "find . -type f -printf '%T@\t%p\n' | sort -t $'\t' -g | head -n -3 | cut -d $'\t' -f 2- | xargs rm"

# Some explanation:

# find lists all files (not directories) in current folder. They are printed out with timestamps.
# sort sorts the lines based on timestamp (oldest on top).
# head prints out the top lines, up to the last 3 lines.
# cut removes the timestamps.
# xargs runs rm for every selected file.

# For you to verify my solution:

# (
# touch -d "6 days ago" test_6_days_old
# touch -d "7 days ago" test_7_days_old
# touch -d "8 days ago" test_8_days_old
# touch -d "9 days ago" test_9_days_old
# touch -d "10 days ago" test_10_days_old
# )

# This creates 5 files with different timestamps in the current folder. Run this first and the code for deleting to test the code.

# 
