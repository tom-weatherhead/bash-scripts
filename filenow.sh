#!/usr/bin/env bash
NOW=$(date --utc +%Y-%m-%d_%H-%M-%S)
echo "$NOW" > $NOW.txt
