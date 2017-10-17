#! /bin/bash
if [[ "$#" -lt 1 ]]; then
	echo "usage $0 <D4J or Testedness>"
	exit
fi

var=$1

directory_unm=""
directory_m=""
patch_folder_unm=""
patch_folder_m=""
extention_m=""
if [[ var -eq "D4J" ]]; then
	directory_unm="/Users/trung/Documents/Umass_rs/bug_fix_minimization/raw_data/D4J_projects"
	directory_m="/Users/trung/Documents/Umass_rs/defects4j/framework/projects"
	patch_folder_unm="merge_diff"
	patch_folder_m="patches"
	extention_m=".src.patch"
else
	directory_unm="/Users/trung/Documents/Umass_rs/bug_fix_minimization/raw_data/testedness_projects_raw_data"
	#not yet have one
	directory_m=""
	patch_folder_unm="merge_diff"
	patch_folder_m="patches"
	extention_m=".dif"
fi
#getting the project list
projects_string=$(ls -1 $directory_unm)
IFS=$'\n| |\t' read -rd '' -a projects <<< "$projects_string"
for p in ${projects[@]}; do
	mkdir $directory_unm/${p}/unm_vs_m/
	#sort the files list in the minimized folder and put them into an array
	mfile_string=$(ls $directory_m/${p}/$patch_folder_m/*${extention_m} | perl -e 'print sort { length($a) <=> length($b) } <>')
	IFS=$'\n| |\t' read -rd '' -a mfiles <<< "$mfile_string"
	#sort the files list in the unminimzed folder and put them into an array
	unmfile_string=$(ls $directory_unm/${p}/$patch_folder_unm/*.dif | perl -e 'print sort { length($a) <=> length($b) } <>')
	IFS=$'\n| |\t' read -rd '' -a unmfiles <<< "$unmfile_string"
	m_nums=${#mfiles[@]}
	umn_nums=${#unmfiles[@]}
	echo "number of minimized files is " $m_nums
	echo "number of unminimized files is " $umn_nums
	i=0
	j=0
	while [ $m_nums -gt $i ] && [ $umn_nums -gt $j ]; do
		#extract bugnumber
		mbase=$(basename ${mfiles[$i]})
		
		IFS=$'.' read -r -a tarray1 <<< "$mbase"
		m_bn=${tarray1[0]}
		echo $m_bn $i
		
		umnbase=$(basename ${unmfiles[$j]})
		IFS=$'_' read -r -a tarray2 <<< "$umnbase"
		umn_bn=${tarray2[1]}
		echo $umn_bn $j
		#find correct files and compare diff
		if [[ m_bn -gt umn_bn ]]; then
			((j++))
		elif [[ m_bn -lt umn_bn ]]; then
			((i++))
		else
			diff -B -b ${mfiles[$i]} ${unmfiles[$j]} > $directory_unm/${p}/unm_vs_m/${umn_bn}.unm_vs_m.dif
			((j++))
			((i++))
		fi  
	done
done




