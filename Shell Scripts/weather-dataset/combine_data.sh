#!/bin/bash

#VARIABLES
CURR_DIR=$(pwd)
FILES="$CURR_DIR/gsod_*"

#FUNCTIONS
function combine_data(){
        for f in $FILES
        do

                FILENAME=$(basename "$f")                                                
                FILES_GSOD="$(pwd)/$FILENAME/*"
                for zf in $FILES_GSOD
                do
                	cat $zf >> /tmp/gsod.op
                done
        done
}

combine_data

