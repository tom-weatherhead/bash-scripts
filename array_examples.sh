#!/bin/bash

# See http://www.thegeekstuff.com/2010/06/bash-array-tutorial

# 1. Declaring an Array and Assigning values

Unix[0]='Debian'
Unix[1]='Red hat'
Unix[2]='Ubuntu'
Unix[3]='Suse'

echo ${Unix[1]}

# $./arraymanip.sh
# Red hat

# 2. Initializing an array during declaration

declare -a Unix=('Debian' 'Red hat' 'Red hat' 'Suse' 'Fedora')

# 3. Print the Whole Bash Array

echo ${Unix[@]}

# Debian Red hat Ubuntu Suse

# 4. Length of the Bash Array

echo ${#Unix[@]}	# Number of elements in the array
echo ${#Unix}		# Number of characters in the first element of the array.i.e Debian

# 5. Length of the nth Element in an Array

# ${#arrayname[n]} should give the length of the nth element in an array.

echo ${#Unix[3]} # length of the element located at index 3 i.e Suse

# 6. Extraction by offset and length for an array

Unix=('Debian' 'Red hat' 'Ubuntu' 'Suse' 'Fedora' 'UTS' 'OpenLinux');
echo ${Unix[@]:3:2}

# Suse Fedora

# 7. Extraction with offset and length, for a particular element of an array

Unix=('Debian' 'Red hat' 'Ubuntu' 'Suse' 'Fedora' 'UTS' 'OpenLinux');
echo ${Unix[2]:0:4}

# Ubun

# 8. Search and Replace in an array elements

# The following example, searches for Ubuntu in an array elements, and replace the same with the word ‘SCO Unix’.

Unix=('Debian' 'Red hat' 'Ubuntu' 'Suse' 'Fedora' 'UTS' 'OpenLinux');

echo ${Unix[@]/Ubuntu/SCO Unix}

# Debian Red hat SCO Unix Suse Fedora UTS OpenLinux

# 9. Add an element to an existing Bash Array

Unix=('Debian' 'Red hat' 'Ubuntu' 'Suse' 'Fedora' 'UTS' 'OpenLinux');
Unix=("${Unix[@]}" "AIX" "HP-UX")
echo ${Unix[7]}

# AIX

# 10. Remove an Element from an Array

Unix=('Debian' 'Red hat' 'Ubuntu' 'Suse' 'Fedora' 'UTS' 'OpenLinux');

unset Unix[3]
echo ${Unix[3]}

# In this example, ${Unix[@]:0:$pos} will give you 3 elements starting from 0th index i.e 0,1,2 and ${Unix[@]:4} will give the elements from 4th index to the last index. And merge both the above output. This is one of the workaround to remove an element from an array.

# 11. Remove Bash Array Elements using Patterns

declare -a Unix=('Debian' 'Red hat' 'Ubuntu' 'Suse' 'Fedora');
declare -a patter=( ${Unix[@]/Red*/} )
echo ${patter[@]}

# Debian Ubuntu Suse Fedora

# 12. Copying an Array

# Expand the array elements and store that into a new array as shown below.

Unix=('Debian' 'Red hat' 'Ubuntu' 'Suse' 'Fedora' 'UTS' 'OpenLinux');
Linux=("${Unix[@]}")
echo ${Linux[@]}

# Debian Red hat Ubuntu Fedora UTS OpenLinux

# 13. Concatenation of two Bash Arrays

# Expand the elements of the two arrays and assign it to the new array.

Unix=('Debian' 'Red hat' 'Ubuntu' 'Suse' 'Fedora' 'UTS' 'OpenLinux');
Shell=('bash' 'csh' 'jsh' 'rsh' 'ksh' 'rc' 'tcsh');

UnixShell=("${Unix[@]}" "${Shell[@]}")
echo ${UnixShell[@]}
echo ${#UnixShell[@]}

# Debian Red hat Ubuntu Suse Fedora UTS OpenLinux bash csh jsh rsh ksh rc tcsh

# 14. Deleting an Entire Array

# unset is used to delete an entire array.

Unix=('Debian' 'Red hat' 'Ubuntu' 'Suse' 'Fedora' 'UTS' 'OpenLinux');
Shell=('bash' 'csh' 'jsh' 'rsh' 'ksh' 'rc' 'tcsh');

UnixShell=("${Unix[@]}" "${Shell[@]}")
unset UnixShell
echo ${#UnixShell[@]}

# 0

# 15. Load Content of a File into an Array

# You can load the content of the file line by line into an array.

# Example file:

# Welcome
# to
# thegeekstuff
# Linux
# Unix

# filecontent=( `cat "logfile" `)
filecontent=( `cat "hello.sh" `)

for t in "${filecontent[@]}"
do
	echo $t
done

echo "Read file content!"

# Welcome
# to
# thegeekstuff
# Linux
# Unix
# Read file content!

# In the above example, each index of an array element has printed through for loop.

# **** BEGIN Bash Associative Array Examples ****

# From https://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash :


Bash 4

Bash 4 natively supports this feature. Make sure your script's hashbang is #!/usr/bin/env bash or #!/bin/bash or anything else that references bash and not sh. Make sure you're executing your script, and not doing something silly like sh script which would cause your bash hashbang to be ignored. This is basic stuff, but so many keep failing at it, hence the re-iteration.

You declare an associative array by doing:

declare -A animals

You can fill it up with elements using the normal array assignment operator:

animals=( ["moo"]="cow" ["woof"]="dog")

Or merge them:

declare -A animals=( ["moo"]="cow" ["woof"]="dog")

Then use them just like normal arrays. "${animals[@]}" expands the values, "${!animals[@]}" (notice the !) expands the keys. Don't forget to quote them:

echo "${animals[moo]}"
for sound in "${!animals[@]}"; do echo "$sound - ${animals[$sound]}"; done

Bash 3

Before bash 4, you don't have associative arrays. Do not use eval to emulate them. You must avoid eval like the plague, because it is the plague of shell scripting. The most important reason is that you don't want to treat your data as executable code (there are many other reasons too).

First and foremost: Just consider upgrading to bash 4. Seriously. The future is now, stop living in the past and suffering from it by forcing stupid broken and ugly hacks on your code and every poor soul stuck maintaining it.

If you have some silly excuse why you "can't upgrade", declare is a far safer option. It does not evaluate data as bash code like eval does, and as such it does not allow arbitrary code injection quite so easily.

Let's prepare the answer by introducing the concepts:

First, indirection (seriously; never use this unless you're mentally ill or have some other bad excuse for writing hacks).

$ animals_moo=cow; sound=moo; i="animals_$sound"; echo "${!i}"
cow

Secondly, declare:

$ sound=moo; animal=cow; declare "animals_$sound=$animal"; echo "$animals_moo"
cow

Bring them together:

# Set a value:
declare "array_$index=$value"

# Get a value:
arrayGet() { 
    local array=$1 index=$2
    local i="${array}_$index"
    printf '%s' "${!i}"
}

Let's use it:

$ sound=moo
$ animal=cow
$ declare "animals_$sound=$animal"
$ arrayGet animals "$sound"
cow

Note: declare cannot be put in a function. Any use of declare inside a bash function turns the variable it creates local to the scope of that function, meaning we can't access or modify global arrays with it. (In bash 4 you can use declare -g to declare global variables - but in bash 4, you should be using associative arrays in the first place, not this hack.)
Summary

Upgrade to bash 4 and use declare -A. If you can't, consider switching entirely to awk before doing ugly hacks as described above. And definitely stay the heck away from eval hackery.
shareimprove this answer
	
edited Aug 18 '16 at 18:31
haridsv
2,23623033
	
answered Aug 12 '10 at 13:09
lhunath
59.2k125469
	
9 	 
	
Don't beat yourself up. It's new in bash 4. – glenn jackman Apr 15 '11 at 16:07
25 	 
	
Ahh, I appreciate the forward-looking sentiment, but "I can't upgrade a server I'm not in charge of" is hardly a silly excuse why you can't upgrade. Many people who have real work to do are, unfortunately, required to do it in a workplace owned by someone else, on servers run by someone else, and if you work in IT I'm sure you know how enjoyable it is for users to come in and demand IT changes. I know this is a sad and tragic state of affairs, but it's life! – David M. Perlman Jan 18 '12 at 20:11
1 	 
	
@Richard: Presumably, you aren't actually using bash. Is your hashbang sh instead of bash, or are you otherwise invoking your code with sh? Try putting this right before your declare: echo "$BASH_VERSION $POSIXLY_CORRECT", it should output 4.x and not y. – lhunath Aug 9 '12 at 16:47
48 	 
	
I love hearing "The future is now" while talking about bash – Arthur Jaouen Dec 7 '12 at 15:12
7 	 
	
@ken it's a licensing issue. Bash on OSX is stuck at the latest non-GPLv3 licensed build. – lhunath Oct 23 '14 at 12:23 
