#! /bin/bash

if [ "$#" -ne 1 ] && [ "$#" -ne 2 ]; then
	echo "$#"
	echo "usage $0 <file directory> <--no-comment (optional)>"
	return 1
fi
#parent directory 
pdirectory=$1
no_comment=$2
projects_String=$(ls -1 $pdirectory)
#get all projects
IFS=$'\n| |\t' read -rd '' -a projects <<< "$projects_String"
echo "number of projects is ${#projects[@]}"
echo ${projects[0]}
current=$(pwd)
echo leaving $current
#iterate through projects
patches="original_patches"

if [[no_comment == "--no-comment"]];then
	patches="remove_comment_patches"
fi
for pn in ${projects[@]}; do 
	rm -r $pdirectory/$pn/merge_diff_${patches}
	mkdir $pdirectory/$pn/merge_diff_${patches}
	echo moving into $pdirectory/$pn/${patches}
	cd $pdirectory/$pn/${patches}
	#capture the sorted file list by length and then name
	file_String=$(ls *.dif | perl -e 'print sort { length($a) <=> length($b) } <>')
	IFS=$'\n| |\t' read -rd '' -a files <<< "$file_String"
	for f in ${files[@]}; do
		IFS=$'.' read -r -a chunks <<< "$f"
		bugnumber=${chunks[0]}
		# append the diff
		cat $f >> $pdirectory/$pn/merge_diff_${patches}/bug_${bugnumber}_merge.dif
	done
	echo leaving $pdirectory/$pn/${patches}
done
cd $current



