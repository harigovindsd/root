#!/bin/bash

# Multi line file content
read -r -d '' MULTILINECONTENT << EOM
frist line
seconnd line
third line
EOM

# Directory Structure Definition
read -r -d '' DIRECTORYSTRUCTURE << EOM
1 shared - $MULTILINECONTENT -
     2 projects - -
          3 movies - Folder for movies -
                4 action - Folder for action movies -
     2 series - Folder for series -
     2 backup - Backup folder -
EOM

function cds() {

	OLD_IFS=$IFS
	IFS=$' \t'
	depth=1
	while (( "$#" )); do

		while (( $1 != $depth )); do
			cd ..
			(( depth-- ))
		done
		shift
		mkdir $1
		cd $1
		(( depth++ ))
		shift 2
		
		#for i in {1..50}; do 
		#	if [[ "$1" = "-" ]]; then
		#		echo "$1"
		#		shift
		#		exit 0
		#	else
		#		echo "test---->$1"	
		#		shift
		#	fi
		content=""
		while ! [[ "$1" =~ "-" ]]; do
			#echo "|-------------------------------------------------"
			#echo "|-param-->$1"
			[ -z $content ] && content=$1 || content=$content" ""$1"
			#echo "|-content---->$content"
			shift
			#echo "|-next--:$1"
			if [[ "$1" =~ "-" ]]; 
			then
				break
			fi
		done
		[ ! -z "$content" ] && echo "$content" >> load.properties
		#echo "created--- file"
		shift
		#echo "next folder $1$2"
	done
	
	if command -v COMMAND &> /dev/null ; then
		echo "COMMAND could not be found"
		while (( 1 != $depth )); do
			cd ..
			(( depth-- ))
		done
		tree .
	fi
}

#---------------------------------------------
# MAIN
#---------------------------------------------
OLD_IFS=$IFS
IFS=$' \t'
cds $DIRECTORYSTRUCTURE
IFS=$OLD_IFS