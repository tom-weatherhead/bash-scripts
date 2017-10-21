#!/bin/sh

INPUT_STRING='abc foo def foo ghi foo jkl'
echo "$INPUT_STRING"
echo "$INPUT_STRING" | sed s/foo/bar/
echo "$INPUT_STRING" | sed s/foo/bar/g
