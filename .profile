# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
# if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
#     if [ -f "$HOME/.bashrc" ]; then
#	. "$HOME/.bashrc"
#     fi
# fi

# set PATH so it includes user's private bin if it exists

# if [ -d "$HOME/bin" ] ; then
#   PATH="$HOME/bin:$PATH"
# fi

HOME_BIN_DIR="$HOME/bin"

if ! [ -e "$HOME_BIN_DIR" ]; then
	echo "$HOME_BIN_DIR does not exist."
elif ! [ -d "$HOME_BIN_DIR" ]; then
	echo "$HOME_BIN_DIR is not a directory."
elif ! [ -r "$HOME_BIN_DIR" ]; then
	echo "$HOME_BIN_DIR is not readable."
elif echo $PATH | grep $HOME_BIN_DIR; then
	echo "$HOME_BIN_DIR is already in the path."
else
	# echo "Adding $HOME_BIN_DIR to the path."
	PATH="$HOME_BIN_DIR:$PATH"
fi
