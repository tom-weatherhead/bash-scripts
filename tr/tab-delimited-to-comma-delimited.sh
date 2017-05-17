#!/bin/bash

INPUT1="ab\tcd"

# This works:
echo -e "$INPUT1" | tr ["\t"] [,]

# This works:
echo -e "$INPUT1" | tr "\t" ,

# This works:
echo -e "$INPUT1" | tr '\t' ,

# This does not work:
echo -e "$INPUT1" | tr \t ,
