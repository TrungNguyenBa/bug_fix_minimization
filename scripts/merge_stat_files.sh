#! /bin/bash

if [[ "$#" -ne 1 ]]; then
	echo "usage $0 <file directory>"
	exit
fi
#parent directory 
pdirectory=$1
projects_String=$(ls -1 $pdirectory)
#get all projects
IFS=$'\n| |\t' read -rd '' -a projects <<< "$projects_String"
echo "number of projects is ${#projects[@]}"
echo ${projects[0]}
current=$(pwd)
echo leaving $current
#iterate through projects
for pn in ${projects[@]}; do 
	rm -r $pdirectory/$pn/merge_diff
	mkdir $pdirectory/$pn/merge_diff
	echo moving into $pdirectory/$pn/original_patches
	cd $pdirectory/$pn/original_patches
	#capture the sorted file list by length and then name
	file_String=$(ls *.dif | perl -e 'print sort { length($a) <=> length($b) } <>')
	IFS=$'\n| |\t' read -rd '' -a files <<< "$file_String"
	for f in ${files[@]}; do
		IFS=$'.' read -r -a chunks <<< "$f"
		bugnumber=${chunks[0]}
		# append the diff
		cat $f >> $pdirectory/$pn/merge_diff/bug_${bugnumber}_merge.dif
	done
	echo leaving $pdirectory/$pn/original_patches
done
cd $current



