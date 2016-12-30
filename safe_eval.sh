#!/bin/bash

safe_eval()
{
	CMD=$(echo $1 | awk '{print $1}')
	
	if which $CMD > /dev/null 2>&1; then
		eval $1
	else
		echo 2>&1
		echo "The command '$CMD' was not found in the path." 2>&1
		echo "To view the path, execute this command: echo \$PATH" 2>&1
	fi
}

safe_eval "$1"