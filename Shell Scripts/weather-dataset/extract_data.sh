#!/bin/bash

#VARIABLES
CURR_DIR=$(pwd)
FILES="$CURR_DIR/*.tar"

#FUNCTIONS
function extract_data(){
	for f in $FILES
	do
		
		FILENAME_FULL=$(basename "$f")
		FILENAME="${FILENAME_FULL%.*}"
		mkdir $FILENAME
		tar -xf $f --directory $FILENAME
		FILES_ZIP="$(pwd)/$FILENAME/*.gz"
		for zf in $FILES_ZIP
		do
			zcat $zf >> /tmp/gsod.op
#		cat "${zf%.gz}" >> /tmp/gsod.op
		done
	done
}

extract_data
