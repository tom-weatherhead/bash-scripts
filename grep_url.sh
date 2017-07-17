#!/bin/bash

cat "$1" | perl -nle 'print $1 while /(http[s]?:\/\/[^"<>\s]*)/gi'

cat "$1" | perl -nle 'print $1 while /(http[s]?:\/\/[^"<>\s]*)/gi' | grep -c -i http

