#!/bin/bash

if [ -z "$1" ]; then
	echo "No parameter."
elif ! [ -d "$1" ]; then
	echo "$1 is not a directory."
else
	echo "$1 is a directory."
fi
