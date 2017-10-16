#! /bin/bash
if [[ "$#" -ne 1 ]]; then
	echo "usage $0 <D4J or Testedness>"
	exit
fi

var=$1
directory_unm=""
directory_m=""
patch_folder_umn=""
patch_folder_m=""
if [[ var -eq "D4J"]]; then
	directory_unm="/Users/trung/Documents/Umass_rs/bug_fix_minimization/raw_data/D4J_projects"
	directory_m="/Users/trung/Documents/Umass_rs/defects4j/framework/projects"
	patch_folder_umn="original_patches"
	patch_folder_m="patches"
else
	directory_umn="/Users/trung/Documents/Umass_rs/bug_fix_minimization/raw_data/testedness_projects_raw_data"
	#not yet have one
	directory_m=""
	patch_folder_umn="original_patches"
	patch_folder_m="patches"
fi






