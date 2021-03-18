#!/usr/bin/env bash

# Run this as a cron job every 5 minutes by editing your crontab (crontab -e) and adding a line like this:
# */5 * * * * /path/to/crontest.sh

mkdir -p /home/tomw/crontest/files
cd /home/tomw/crontest/files
NOW=$(date -u +%Y-%m-%d_%H-%M-%S)
echo "$NOW" > $NOW.txt

# Delete all *.txt files except for the most recent three:
ls -At *.txt | tail -n +4 | xargs rm -- 2>/dev/null

