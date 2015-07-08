#!/bin/bash
#
#Author:: Sai Karthik Thati (<karthik.thati@cloudwick.com>)
#Description:: Script to manage conatacts
#Supported OS:: CentOS
#Version:: 0.1
#

#GLOBAL VARIABLES (script-use only)
FILE_NAME=""
FILE_PATH=""

#COLORS
export GREP_OPTIONS='--color=auto' GREP_COLOR='100;8'

#FUNCTIONS
function validate_file(){
	if [ -z $(find "$PWD" -iname "$FILE_NAME" ) ]; then		
		echo "File does not exist. Creating new file in current directory."
		touch "$FILE_NAME"
		FILE_PATH="$PWD/$FILE_NAME"
	else
		FILE_PATH=$(find "$PWD" -iname "$FILE_NAME")
	fi
}

function create_record(){
	#TAKE INPUT FROM USER START
	echo ""
	echo "Please enter the following contact details:"
	read -p "First Name: " FIRST_NAME 
	read -p "Last Name: " LAST_NAME
	read -p "Address: " ADDRESS
	read -p "City: " CITY
	read -p "State: " STATE
	read -p "Zip: " ZIP
	#TAKE INPUT FROM USER END
	
	#read -r -p "Are you sure? [y/N]" RESPONSE
	read -p "Are you sure? [y/n] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo "$FIRST_NAME:$LAST_NAME:$ADDRESS:$CITY:$STATE:$ZIP" >> "$FILE_PATH"
		if [ $? -eq 0 ]; then
			 echo ""
               		 echo "Record successfully stored"
			 read -p "Press [Enter] to continue..."
	        else
			 echo ""
	               	 echo "OOPS||| Something went wrong"
      			 read -p "Press [Enter] to continue..."
        	fi

	else
		create_record
	fi
}

function view_records(){
	echo ""
	echo ""
	echo "First Name	Last Name	Address		City	State	Zip"
	echo "===================================================================="
	k=0
	while IFS=':' read -r FIRSTNAME LASTNAME ADDRESS CITY STATE ZIP
	do
	   echo "$FIRSTNAME		$LASTNAME		$ADDRESS		$CITY	$STATE	$ZIP"
        	((k++))
	done < "$FILE_PATH"
	echo ""
	echo "There are $k records"
	read -p "Press [Enter] to continue..."
}

function search_records(){
	read -p "Enter search pattern: " SEARCH_PATTERN
	grep -i "$SEARCH_PATTERN" "$FILE_PATH"
	read -p "Press [Enter] to continue..."
}

function delete_records(){
	read -p "Enter search pattern or press [Enter] to delete all records: " SEARCH_PATTERN
	read -p "Are you sure? [y/n] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
		#check for empty
		if [ -z "$SEARCH_PATTERN" ]; then
			cat /dev/null > "$FILE_PATH"
		else
			sed -i "/$SEARCH_PATTERN/ d" "$FILE_PATH"
		fi
		if [ $? -eq 0 ]; then
                         echo ""
                         echo "Records successfully deleted"
                         read -p "Press [Enter] to continue..."
                else
                         echo ""
                         echo "OOPS||| Something went wrong"
                         read -p "Press [Enter] to continue..."
		fi
	fi
}

function usage(){
	script=$0
	cat <<USAGE
Syntax
`basename ${script}` -f
-f: specify contacts file path. Script creates a new file in the current directory if the file does not exist
USAGE
	exit 1
}


while getopts h:f: opt; do
	case "${opt}" in
	h) 
		usage
		;;
	f)	
		FILE_NAME=$OPTARG
		validate_file
		;;
	\?)
		usage
		;;
	esac
done

if [ $# -eq 0 ]; then
    usage
fi

while :
do
	echo ""
        echo "======================="
        echo "1) create contact"
        echo "2) list all contacts"
        echo "3) search contact"
        echo "4) delete contact"
        echo "5) exit"
        echo "======================="
        echo "enter the choice number"
        read option


    case "${option}" in
        1)
                create_record
                ;;
        2)
                view_records
                ;;
        3)
                search_records
                ;;
        4)
                delete_records
                ;;
        5)
                exit 1
                ;;
    esac
done

