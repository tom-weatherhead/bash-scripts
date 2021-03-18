#!/usr/bin/env bash
# NOW=$(date --utc +%Y-%m-%d_%H-%M-%S)
NOW=$(date -u +%Y-%m-%d_%H-%M-%S)
echo "$NOW" > $NOW.txt
