#!/bin/bash

# Demonstrate how to write and call a Bash function that returns a value that can be interpreter as a Boolean value:

user_is_root()
{
	# !!! Remember: In *nix exit codes, 0 is OK (true), and anything non-zero is an error (false).
	# return [ `id -u` == 0 ]								# No.
	[ `id -u` == 0 ] && return 0 || return 1
}

# [ $(user_is_root) ] && echo "Root!" || echo "Not root."	# No.
# [ `user_is_root` ] && echo "Root!" || echo "Not root."	# No.
user_is_root && echo "Root!" || echo "Not root."			# Yes!

# **** Older stuff: ****

is_toasty_version1()
{
	[[ "$1" =~ Toast ]] && echo 1 || echo
}

is_toasty_version2()
{
	if [[ "$1" =~ Toast ]]; then
		echo 1
	else
		echo
	fi
}

# [ $(is_a_non_negative_integer 128) ] && echo "128 is a non neg int!" || echo "128 is NOT a non neg int."
# [ $(is_a_non_negative_integer "128") ] && echo "128 is a non neg int!" || echo "128 is NOT a non neg int."
# [ $(is_a_non_negative_integer "abc.mp3") ] && echo "abc.mp3 is a non neg int!" || echo "abc.mp3 is NOT a non neg int."
# [ $(is_a_non_negative_integer) ] && echo "(empty) is a non neg int!" || echo "(empty) is NOT a non neg int."

toasty_test()
{
	[ $(is_toasty_version1 "$2") ] && { # The double quotes around $2 here are essential.
		echo "is_toasty_version1, test 1: $1 is Toasty: Yes!"
	} || {
		echo "is_toasty_version1, test 1: $1 is Toasty: No."
	}

	if [ $(is_toasty_version1 "$2") ]; then
		echo "is_toasty_version1, test 2: $1 is Toasty: Yes!"
	else
		echo "is_toasty_version1, test 2: $1 is Toasty: No."
	fi

	[ $(is_toasty_version2 "$2") ] && {
		echo "is_toasty_version2, test 1: $1 is Toasty: Yes!"
	} || {
		echo "is_toasty_version2, test 1: $1 is Toasty: No."
	}

	if [ $(is_toasty_version2 "$2") ]; then
		echo "is_toasty_version2, test 2: $1 is Toasty: Yes!"
	else
		echo "is_toasty_version2, test 2: $1 is Toasty: No."
	fi
}

TEST_STRING1="This is Toasty"
TEST_STRING2="This is untoasted"

toasty_test "TEST_STRING1" "$TEST_STRING1"
toasty_test "TEST_STRING2" "$TEST_STRING2"
