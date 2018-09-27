#!/usr/bin/env bash

# Run this as root? Or as user or group www-data?

# Run this as a cron job every 5 minutes by editing your crontab (crontab -e) and adding a line like this:
# */5 * * * * /path/to/cron_git_server.sh

# NOW=$($(/usr/bin/env date) --utc +%Y-%m-%d_%H-%M-%S)
NOW=$(date --utc +%Y-%m-%d_%H-%M-%S)

mkdir -p /srv/gitbackups
# cd /srv/git
# $(/usr/bin/env tar) cjvf "/srv/gitbackups/git_backup_$NOW.tar.bz2" *
# tar cjvf "/srv/gitbackups/git_backup_$NOW.tar.bz2" *
# Use "." instead of "*" because "*" is expanded before -C changes the directory; see https://unix.stackexchange.com/questions/199038/tar-unix-not-changing-directory
tar -cjvf "/srv/gitbackups/git_backup_$NOW.tar.bz2" -C /srv/git .
chown -R tomw:tomw /srv/gitbackups

# Delete all *.bz2 files except for the most recent three:
ls -At /srv/gitbackups/*.bz2 | tail -n +4 | xargs rm -- 2>/dev/null
