#!/bin/bash

# flac2alac By Arlindo \"Nighto\" Pereira <nighto@nighto.net>
# (C) 2010. Licensed under GPLv3
# Modified by Jeffrey Paul <sneak@datavibe.net>
# Inspired by MetalMusicAddict's script

# This script converts FLAC files to ALAC format, preserving metadata and album art.
# Requires ImageMagick, mpeg4ip (for mp4tags), recent flac, and ffmpeg with ALAC and FLAC support.
function usage() {
	echo ""
    echo "Usage: $0 [-d] file1.flac "
	echo ""
    echo "-d        Delete the original FLAC files after successful conversion."
	echo ""
    echo "file.flac Path to the FLAC file or files to be converted. Supports wildcard *.flac for batch conversion."
	echo ""
	echo "This tool also embeds album artwork if you have any on your directory and your files don't have any album artwork."
	echo ""
}

# Check for no arguments
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

# Check for help option
if [ "$1" == "-h" ]; then
    usage
    exit 0
fi

function _convert_flac2alac {
    # Prepare file names and paths
    local NF="`basename \"$1\" .flac`.m4a"
    local D="`dirname \"$1\"`"

    # Decode FLAC to temporary WAV file
    flac -dc "$1" > "${D}/.flacdecode.${NF}.wav"
    if [ $? -ne 0 ]; then
        echo "ERROR: Corrupt or invalid FLAC file, exiting." >&2
        exit 1
    fi

    # Extract metadata using metaflac and sed to remove the tag prefix
    local ARTIST="`metaflac --show-tag=ARTIST \"$1\" | sed s/ARTIST=//ig`"
    local ALBUMARTIST="`metaflac --show-tag=ALBUMARTIST \"$1\" | sed s/ALBUMARTIST=//ig`"
    local TITLE="`metaflac --show-tag=TITLE \"$1\" | sed s/TITLE=//ig`"
    local ALBUM="`metaflac --show-tag=ALBUM \"$1\" | sed s/ALBUM=//ig`"
    local DATE="`metaflac --show-tag=DATE \"$1\" | sed s/DATE=//ig`"
    local GENRE="`metaflac --show-tag=GENRE \"$1\" | sed s/GENRE=//ig`"
    local TRACKNUMBER="`metaflac --show-tag=TRACKNUMBER \"$1\" | sed s/TRACKNUMBER=//ig`"
    local TRACKTOTAL="`metaflac --show-tag=TRACKTOTAL \"$1\" | sed s/TRACKTOTAL=//ig`"
    local DISCNUMBER="`metaflac --show-tag=DISCNUMBER \"$1\" | sed s/DISCNUMBER=//ig`"
    local DISCTOTAL="`metaflac --show-tag=DISCTOTAL \"$1\" | sed s/DISCTOTAL=//ig`"
    local DESCRIPTION="`metaflac --show-tag=DESCRIPTION \"$1\" | sed s/DESCRIPTION=//ig`"
    local COMPOSER="`metaflac --show-tag=COMPOSER \"$1\" | sed s/COMPOSER=//ig`"
    local LYRICS="$(metaflac --show-tag=LYRICS "${1}" | sed s/LYRICS=//ig)"

    # Determine the MIME type of the embedded picture
	local ARTFILE=".arttmp.${NF}"
    
	# Extracting the MIME type of the embedded picture to determine its format
	local ARTFORMAT=$(metaflac --export-picture-to=- "$1" | file -i -b - | awk '{split($1,a,";"); print a[1]}')
	echo "ARTFORMAT: $ARTFORMAT"
	echo "Arttext : $ARTEXT"

	# THIS PART WILL BE REWRITTEN
    # CHECK ARTFORMAT, MAKE LOWERCASE, SET ARTFILE TO IT

	# Proceed with the rest of the script based on ARTFORMAT's value
	if [ "$ARTFORMAT" != "application/x-empty" ]; then
		echo "ARTFILE : $ARTFILE"
		echo "Arttext: $ARTEXT"

		if [ "$ARTFORMAT" = "image/png" ]; then ARTEXT="png"; fi
		if [ "$ARTFORMAT" = "image/jpeg" ]; then ARTEXT="jpg"; fi
		if [ "$ARTFORMAT" = "JPEG" ]; then ARTEXT="jpg"; fi
		if [ -z "$ARTEXT" ]; then
			ARTFILE=$(find . -type f \( -iname "*.jpg" -o -iname "*.png" \) -print -quit)
			echo "Directory artfile : $ARTFILE"
			if [ -n "$ARTFILE" ]; then
    			echo "Found file: $ARTFILE"
				
			else
    			echo "No .jpg or .png files found."
				echo "Unknown embedded album art format: ${ARTFORMAT}, cannot continue." >&2
				exit 1
			fi
			
		else
			ARTFILE=".arttmp.${NF}.${ARTEXT}"  # Ensure the file extension is appended
			metaflac --export-picture-to="${D}/${ARTFILE}" "$1"
		fi
		echo "ARTFILE : $ARTFILE"
		echo "Arttext: $ARTEXT"

        # Resize ARTFILE to 500x500 pixel , convert to jpg
        # and save it as non progressive jpg, to be compatible with RockBox
        if [ "${ARTEXT}" = "png" ]
        then
            convert "${D}/${ARTFILE}" -resize 500x500 -interlace none "${D}/${ARTFILE}.jpg"
            ARTFILE="${ARTFILE}.jpg"
        else
            convert "${D}/${ARTFILE}" -resize 500x500 -interlace none "${D}/${ARTFILE}"
        fi

	fi

    ffmpeg -hide_banner -i "${D}/.flacdecode.${NF}.wav" \
    ${ARTFILE:+-i "${D}/${ARTFILE}"} \
    -map 0:a ${ARTFILE:+-map 1:v} \
    -metadata title="$TITLE" \
    -metadata artist="$ARTIST" \
    -metadata album_artist="$ALBUMARTIST" \
    -metadata album="$ALBUM" \
    -metadata genre="$GENRE" \
    -metadata date="$DATE" \
    -metadata track="$TRACKNUMBER/$TRACKTOTAL" \
    -metadata disc="$DISCNUMBER/$DISCTOTAL" \
    -metadata composer="$COMPOSER" \
    -metadata comment="$DESCRIPTION" \
    -metadata lyrics="${LYRICS}" \
    ${ARTFILE:+-disposition:v:0 attached_pic} \
    -c:a alac ${ARTFILE:+-c:v copy} \
    "${D}/.tmp.${NF}"
    
    if [ $? -ne 0 ]; then
        echo "Problem running conversion, exiting." >&2
        exit 1
    fi

    # Finalize: rename temporary ALAC file to final name
    mv "${D}/.tmp.${NF}" "${D}/${NF}"
    echo "Successfully converted $1 to ${D}/${NF}"

    # Clean up the temporary decoded WAV file
    rm -f "${D}/.flacdecode.${NF}.wav"

    # Option to delete original FLAC file after successful conversion
    if [ $DELETE_WHEN_DONE -eq 1 ]; then
        rm "$1"
        echo "Original FLAC file deleted."
    fi
}

# Main script logic: parse arguments and call conversion function
DELETE_WHEN_DONE=0

for filename in "$@"; do
    if [ "$filename" = "-d" ]; then
        DELETE_WHEN_DONE=1
    elif [ -d "$filename" ]; do
        IFS=$'\n'
        for one_filename in $(find "$filename" -type f -iname "*.flac"); do
            unset IFS
            _convert_flac2alac "$one_filename"
        done
    elif [ -f "$filename" ]; then
        _convert_flac2alac "$filename"
    fi
done

