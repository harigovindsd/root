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
		content=""
		
		while ! [[ "$1" =~ "-" ]]; do
			[ -z "$content" ] && content=$1 || content=$content" ""$1"
			shift
			if [[ "$1" =~ "-" ]]; 
			then
				break
			fi
		done
		[ ! -z "$content" ] && echo "$content" >> load.properties 		#filename is hardcoded. Can be updated to be picked from structure definition 
		shift
	done
	
	if command -v tree &> /dev/null ; then
		while (( 1 != $depth )); do
			cd ..
			(( depth-- ))
		done
		cd -
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
