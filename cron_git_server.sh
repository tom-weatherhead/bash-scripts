#!/usr/bin/env bash

# Run this script as root? Or as user or group www-data?

# Run this as a cron job every day by editing your crontab (crontab -e) and adding a line like this:
# 0 0 * * * /path/to/cron_git_server.sh

# Every 5 minutes:
# */5 * * * * /path/to/cron_git_server.sh

SRCDIR="$1"
DESTDIR="$2"
NOW=$(date -u +%Y-%m-%d_%H-%M-%S)
mkdir -p "$DESTDIR"
# Use "." instead of "*" because "*" is expanded before -C changes the directory; see https://unix.stackexchange.com/questions/199038/tar-unix-not-changing-directory
tar -cjf "$DESTDIR/git_backup_$NOW.tar.bz2" -C "$SRCDIR" .
chown -R tomw:tomw "$DESTDIR"

# Keep only the three most recent backups
# Don't put double quotes around $DESTDIR/git_backup_*.tar.bz2 :
ls -At $DESTDIR/git_backup_*.tar.bz2 | tail -n +4 | xargs rm -- 2>/dev/null
