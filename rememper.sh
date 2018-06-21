#!/bin/bash

#==============================================================================
#title           : rememper
#description     : Remember and restore permission and ownership attributes
#		   recursively in a directory		  
#author		 : Paschalis Tsilias
#date            : 2018-06-14
#version         : 0.1
#usage		 : -c | -r target-dir filename
#notes           : Not extensively tested, please report any issues
		  
#==============================================================================


# For heavier usage, I would advise using a professional tool, like
# sudo apt/yum install acl
# To Store/Restore permissions and ownership recursively
# getfacl -R yourDirectory > permissions.acl
# setfacl --restore=permissions.acl

if [[ $1 == "-c" ]] || [[ $1 == "--create" ]]; then  mode="create"
elif [[ $1 == "-r" ]] || [[ $1 == "--restore" ]]; then mode="restore"
elif [[ $1 == "-d" ]] || [[ $1 == "--diff" ]]; then mode="diff"
elif [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
	echo "Usage : [ -c , --create | -r, --restore | -d, --diff ] <target-dir> <filename>"
else 
	echo "Unknown Mode"
	echo "Usage : [ -c , --create | -r, --restore | -d, --diff ] <target-dir> <filename>"
fi




if [[ $mode == "create" ]]; then
    echo "Taking a snapshot of dir '$2' attributes, on . . . '$3'"
	find "$2" | xargs stat -c%u,%g,%a,%n > "$3"
fi

if [[ $mode == "restore" ]]; then
	echo "Restoring attributes in dir '$2' attributes, using '$3'. . ."
	
	cat "${3}" | while read ln; do
		u=$( echo "${ln}" | cut -d, -f1)
		g=$( echo "${ln}" | cut -d, -f2)
		a=$( echo "${ln}" | cut -d, -f3)
		f=$( echo "${ln}" | cut -d, -f4)
		echo "chown-ing ${u}:${g} ${f}"
		chown "${u}":"${g}" "${f}"
		echo "chmod-ing ${a} ${f}"
		chmod "${a}" "${f}"
	done
fi

if [[ $mode == "diff" ]]; then
	find "$2" | xargs stat -c%u,%g,%a,%n > current_permissions
	echo "Lines Missing in current attributes file"
	diff current_permissions "$3" | grep '>' 
	echo ""
	echo "Lines Missing in backup attributes file"
	diff current_permissions "$3" | grep '<' 
fi
