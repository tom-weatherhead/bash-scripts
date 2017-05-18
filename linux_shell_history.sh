#!/bin/bash
# history | awk '{a[$2]++ } END{for(i in a){print a[i] i}}' | sort -rn | head
# history | awk "{a['$'4]++ } END{for(i in a){print a[i], i}}" | sort -rn | head
#history | awk '{a[$2]++ } END{for(i in a){print a[i], i}}' | sort -rn | head
# ls
# history -a

# ****

# From https://askubuntu.com/questions/546556/how-can-i-use-history-command-in-a-bash-script :

# history is disabled by default in non-interactive shells by bash. You have to enable it.

# The script should look like this:

#!/bin/bash

# HISTFILE=~/.bash_history  # Set the history file.
# HISTTIMEFORMAT='%F %T '   # Set the hitory time format.
set -o history            # Enable the history.

# file="/home/buckwheat/Documents/history.txt"

# history >> $file          # Save the history.
# history -cw               # Clears the history of the current session.

# This just prints the command history since this script began running.
history | awk '{a[$4]++ } END{for(i in a){print a[i], i}}' | sort -rn | head
