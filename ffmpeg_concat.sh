#!/bin/bash

# See https://trac.ffmpeg.org/wiki/Concatenate

# **** BEGIN Web page excerpt ****

# Concatenating media files

# Contents

    # Concatenation of files with same codecs
        # Concat demuxer
        # Concat protocol
    # Concatenation of files with different codecs
        # Concat filter
        # Using an external script
        # Pipe-friendly formats

# If you have media files with exactly the same codec and codec parameters you can concatenate them as described in "Concatenation of files with same codecs". If you have media with different codecs you can concatenate them as described in "Concatenation of files with different codecs" below.
# Concatenation of files with same codecs

# There are two methods within ffmpeg that can be used to concatenate files of the same type: the concat ''demuxer'' and the concat ''protocol''. The demuxer is more flexible - it requires the same codecs, but different container formats can be used; and it can be used with any container formats, while the protocol only works with a select few containers. However, the concat protocol is available in older versions of ffmpeg, where the demuxer isn't. The demuxer also requires that the inputs have a consistent bitrate setting, the concat protocol is more flexible in this regard. 

# Concat demuxer

# The concat demuxer was added to FFmpeg 1.1. You can read about it in the documentation.
# Instructions

# Create a file mylist.txt with all the files you want to have concatenated in the following form (lines starting with a # are ignored):

# this is a comment
# file '/path/to/file1'
# file '/path/to/file2'
# file '/path/to/file3'

# Note that these can be either relative or absolute paths. Then you can stream copy or re-encode your files:

# ffmpeg -f concat -safe 0 -i mylist.txt -c copy output

# The -safe 0 above is not required if the paths are relative.

# It is possible to generate this list file with a bash for loop, or using printf. Either of the following would generate a list file containing every *.wav in the working directory:

# with a bash for loop
# for f in ./*.wav; do echo "file '$f'" >> mylist.txt; done
# or with printf
# printf "file '%s'\n" ./*.wav > mylist.txt

# On Windows Command-line:

# (for %i in (*.wav) do @echo file '%i') > mylist.txt

# If your shell supports process substitution (like Bash and Zsh), you can avoid explicitly creating a list file and do the whole thing in a single line. This would be impossible with the concat protocol (see below). Make sure to generate absolute paths here, since ffmpeg will resolve paths relative to the list file your shell may create in a directory such as "/proc/self/fd/".

# ffmpeg -f concat -safe 0 -i <(for f in ./*.wav; do echo "file '$PWD/$f'"; done) -c copy output.wav
# ffmpeg -f concat -safe 0 -i <(printf "file '$PWD/%s'\n" ./*.wav) -c copy output.wav
# ffmpeg -f concat -safe 0 -i <(find . -name '*.wav' -printf "file '$PWD/%p'\n") -c copy output.wav

# You can also loop a video. This example will loop input.mkv 10 times:

# for i in {1..10}; do printf "file '%s'\n" input.mkv >> mylist.txt; done
# ffmpeg -f concat -i mylist.txt -c copy output.mkv

# Concatenation becomes troublesome, if next clip for concatenation does not exist at the moment, because decoding won't start until the whole list is read. However, it is possible to refer another list at the end of the current list:

#!/bin/bash

# fn_concat_init() {
    # echo "fn_concat_init"
    # concat_pls=`mktemp -u -p . concat.XXXXXXXXXX.txt`
    # concat_pls="${concat_pls#./}"
    # echo "concat_pls=${concat_pls:?}"
    # mkfifo "${concat_pls:?}"
    # echo
# }

# fn_concat_feed() {
    # echo "fn_concat_feed ${1:?}"
    # {
        # >&2 echo "removing ${concat_pls:?}"
        # rm "${concat_pls:?}"
        # concat_pls=
        # >&2 fn_concat_init
        # echo 'ffconcat version 1.0'
        # echo "file '${1:?}'"
        # echo "file '${concat_pls:?}'"
    # } >"${concat_pls:?}"
    # echo
# }

# fn_concat_end() {
    # echo "fn_concat_end"
    # {
        # >&2 echo "removing ${concat_pls:?}"
        # rm "${concat_pls:?}"
        # not writing header.
    # } >"${concat_pls:?}"
    # echo
# }

# fn_concat_init

# echo "launching ffmpeg ... all.mkv"
# timeout 60s ffmpeg -y -re -loglevel warning -i "${concat_pls:?}" -pix_fmt yuv422p all.mkv &

# ffplaypid=$!


# echo "generating some test data..."
# i=0; for c in red yellow green blue; do
    # ffmpeg -loglevel warning -y -f lavfi -i testsrc=s=720x576:r=12:d=4 -pix_fmt yuv422p -vf "drawbox=w=50:h=w:t=w:c=${c:?}" test$i.mkv
    # fn_concat_feed test$i.mkv
    # ((i++));
    # echo
# done
# echo "done"

# fn_concat_end

# wait "${ffplaypid:?}"

# echo "done encoding all.mkv"

# Concat protocol

# While the demuxer works at the stream level, the concat protocol works at the file level. Certain files (mpg and mpeg transport streams, possibly others) can be concatenated. This is analogous to using cat on UNIX-like systems or copy on Windows.
# Instructions

# ffmpeg -i "concat:input1.mpg|input2.mpg|input3.mpg" -c copy output.mpg

# If you have MP4 files, these could be losslessly concatenated by first transcoding them to mpeg transport streams. With h.264 video and AAC audio, the following can be used:

# ffmpeg -i input1.mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts intermediate1.ts
# ffmpeg -i input2.mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts intermediate2.ts
# ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc output.mp4

# If you're using a system that supports named pipes, you can use those to avoid creating intermediate files - this sends stderr (which ffmpeg sends all the written data to) to /dev/null, to avoid cluttering up the command-line:

# mkfifo temp1 temp2
# ffmpeg -i input1.mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts temp1 2> /dev/null & \
# ffmpeg -i input2.mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts temp2 2> /dev/null & \
# ffmpeg -f mpegts -i "concat:temp1|temp2" -c copy -bsf:a aac_adtstoasc output.mp4

# All MPEG codecs (H.264, MPEG4/divx/xvid, MPEG2; MP2, MP3, AAC) are supported in the mpegts container format, though the commands above would require some alteration (the -bsf bitstream filters will have to be changed).

# Concatenation of files with different codecs

# ...

# Using an external script

# With any vaguely-modern version of ffmpeg, the following script is made redundant by the advent the concat filter, which achieves the same result in a way that works across platforms. It is a clever workaround of ffmpeg's then-limitations, but most people (i.e. anyone not stuck using an ancient version of ffmpeg for whatever reason) should probably use one of the methods listed above. 

# ...

# **** END Web page excerpt ****

SOURCE_FILE_PATH="$1"

# Get file extension: see http://tecadmin.net/how-to-extract-filename-extension-in-shell-script/
SOURCE_FILENAME_WITH_EXTENSION=$(basename "$SOURCE_FILE_PATH")

SOURCE_EXTENSION="${SOURCE_FILENAME_WITH_EXTENSION##*.}" # If SOURCE_FILENAME_WITH_EXTENSION contains one or more dots, this expression evaluates to the substring after the last dot; otherwise, it evaluates to all of SOURCE_FILENAME_WITH_EXTENSION

# To get the filename without the extension, see https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
# Is this SOURCE_FILENAME_BASE or is it all of SOURCE_FILE_PATH minus the extension? -> The former: Just the filename base. E.g. If SOURCE_FILE_PATH is /dir1/dir2/dir3/filename.ext, then SOURCE_FILENAME_BASE is just "filename".
SOURCE_FILENAME_BASE=$(basename -s ."$SOURCE_EXTENSION" "$SOURCE_FILE_PATH")

# 0) Use ffmpeg_segments.sh to generate the segments (*Segment*.mp4), then delete the unwanted segments:

# ffmpeg -i "$SOURCE_FILE_PATH" -acodec copy -f segment -vcodec copy -reset_timestamps 1 -map 0 "$SOURCE_FILENAME_BASE.Segment%06d.mp4"

# 1) GenerateFileList.sh

# 1a) Using sed:
# find `pwd` -maxdepth 1 -name "*Segment*" | sed -rn 's/^\/(cygdrive|mnt)\/([a-zA-Z])/\U\2:/;s/\//\\\\/g;s/^(.*)$/file \x27\1\x27/p' > FileList.txt

find "`pwd`" -maxdepth 1 -name "*.mp4" | sed -rn 's/^\/(cygdrive|mnt)\/([a-zA-Z])/\U\2:/;s/\//\\\\/g;s/^(.*)$/file \x27\1\x27/p' > FileList.txt

# 1b) Using awk:

# Awk stage 1: At the start of the input, convert "/cygdrive/x" or "/mnt/x" to "x:" (for any letter "x")
# - The "g" can be replaced with 1
# Awk stage 2: Convert the first character of the input (the drive letter "x" from stage 1) to uppercase
# Awk stage 3: Convert every forward slash in the input to a pair of backslashes
# Awk stage 4: Prepend "file '" and append "'" to each line of the input

# find `pwd` -maxdepth 1 -name "*Segment*" | awk '{ print gensub(/^\/(cygdrive|mnt)\/([a-zA-Z])/, "\\2:", "g") }' | awk '{ sub(".", substr(toupper($i),1,1) , $i) }1' | awk '{ gsub("/","\\\\") }1' | awk '{ print "file '\''" $0 "'\''" }'

# 1c) Using perl:
# find `pwd` -maxdepth 1 -name "*Segment*" | perl -nle 's/\/(cygdrive|mnt)\/([a-zA-Z])/\U$2:/; s/\//\\\\/g; print "file '\''$_'\''";' > FileList.Perl.txt

# 2) Concat.sh

ffmpeg -f concat -safe 0 -i FileList.txt -c copy "$SOURCE_FILENAME_BASE.ConcatenatedSegments.mp4"

# 3) Cleanup

# rm -f FileList.txt
[ -f FileList.txt ] && rm -f FileList.txt	# If FileList.txt is an existing file, then remove it.
[ -f FileList.Awk.txt ] && rm -f FileList.Awk.txt
[ -f FileList.Perl.txt ] && rm -f FileList.Perl.txt
