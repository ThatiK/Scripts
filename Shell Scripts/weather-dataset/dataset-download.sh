#!/bin/bash

#VARIABLES
DATASET_PATH=ftp://ftp.ncdc.noaa.gov/pub/data/gsod
START_INDEX=1929
END_INDEX=2014

#FUNCTIONS
function get_data(){
	for (( c="$START_INDEX"; c<="$END_INDEX"; c++ ))
	do
	   wget "$DATASET_PATH/$c/*.tar"
	done	
}

get_data
