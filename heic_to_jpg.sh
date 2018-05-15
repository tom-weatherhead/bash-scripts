#!/bin/bash

# find . -iname "*.HEIC" -exec /path/to/heic_to_jpg.sh {} \;

# If tifig gives you this error: "No ftyp box found! This cannot be a HEIF image." ...
# then:
# From https://github.com/monostream/tifig/blob/master/src/main.cpp
# Sanity check: When you edit a HEIC image on iOS 11 it's saved as JPEG instead of HEIC but still has .heic ending.
# Starting tifig on such a file, nokia's heif library goes into an endless loop.
# So check if the file starts with an 'ftyp' box.
# -> TomW 2018-04-29 : In this case, there is no need to convert the file; just change the extension from .HEIC to .jpg .

# E.g. a real HEIC file:
# $ file IMG_6441.HEIC
# IMG_6441.HEIC: ISO Media

# E.g. a .jpg panorama file from iOS 11, mislabelled as an HEIC file:
# $ file IMG_6442.HEIC
# IMG_6442.HEIC: JPEG image data, JFIF standard 1.01, aspect ratio, density 1x1, segment length 16, Exif Standard: [TIFF image data, big-endian, direntries=11, manufacturer=Apple, model=iPhone 7 Plus, orientation=upper-left, xresolution=166, yresolution=174, resolutionunit=2, software=11.3, datetime=2018:04:28 15:58:27, GPS-Data], baseline, precision 8, 8499x1882, frames 3

SOURCE_FILE_PATH="$1"
SOURCE_FILENAME_WITH_EXTENSION=$(basename "$SOURCE_FILE_PATH")
SOURCE_EXTENSION="${SOURCE_FILENAME_WITH_EXTENSION##*.}" # If 
SOURCE_FILENAME_BASE=$(basename -s ."$SOURCE_EXTENSION" "$SOURCE_FILE_PATH")
DST_FILE_PATH="$SOURCE_FILENAME_BASE.jpg"

if ! [ -f "$DST_FILE_PATH" ]; then
	echo "$1"
	/home/tomw/bin/tifig "$SOURCE_FILE_PATH" "$DST_FILE_PATH"
fi
