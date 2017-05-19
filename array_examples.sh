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
