#!/bin/bash

# for file in *.mov; do change_file_extension_to_mp4 "$file"; done

# for file in *
for file in *.*
	ffmpeg_convert_to_mp4 -5 -p 1 $file
	sleep 30
done
