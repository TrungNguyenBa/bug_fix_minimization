#!/bin/bash
die() {
    echo $1
    exit 1
}
[ "$BFM" != "" ] || die "BFM is not set!"
current=$(pwd)
echo "living $current"
echo "moving to $BFM"
echo 
echo .........
echo
testedness_repos="/Users/trung/Documents/Umass_rs/testedness_projects"
numprojects=$(cat "$BFM/raw_data/testedness_project_names.txt" | wc -l)

for nf in $(seq 1 $numprojects); do
    pid=$(head -${nf} $BFM/raw_data/testedness_project_names.txt | tail -1 )
    dir_project="$BFM/raw_data/testedness_projects_raw_data/$pid"
    dir_original="$dir_project/original_patches"
    cmake -E make_directory $dir_original

    echo working on $dir_original
    # Determine the number of bugs for this project
    num_bugs=$(cat $dir_project/commit-data.csv | wc -l)
    # Iterate over all bugs for this project
    echo "checking project $pid ($num_bugs bugs)"
    for bid in $(seq 2 $num_bugs); do
    	#get the line
    	echo "reading fille $dir_project/commit-data.csv"
    	line=$(head -${bid} $dir_project/commit-data.csv | tail -1 )
    	#splitting the line into string array
    	IFS=$',' read -r -a array <<< "$line"
    	#get teh fixed version from the array
    	fixed_string=${array[2]}
        fixed=$(echo "$fixed_string" | tr -d '"')
        #get the faulted version, assumming that the pervious version of the fixed is the faulted one
        faulted=$(git -C $testedness_repos/$pid show -s ${fixed}^1 --format="%H")
    	echo "faulted version hash: $faulted"
    	echo "fixed version hash: $fixed"
    	#get the number of file changes
    	git -C $testedness_repos/$pid whatchanged -1 $fixed $faulted  --pretty=format:'%h : %s' > $dir_original/${bid}.changed_files_list.txt
    	num_files=$(cat $dir_original/${bid}.changed_files_list.txt | wc -l)
    	#iterate through the file
    	for fid in $(seq 2 $num_files); do
    		file_line=$(head -${fid} $dir_original/${bid}.changed_files_list.txt | tail -1 )
    		IFS=$' |\t|\\' read -r -a chunks <<< "$file_line"
    		echo file_line is $file_line
    		file_name=${chunks[${#chunks[@]}-1]}
    		echo file_name is $file_name
    		#get the diff between versions for this file
    		git -C $testedness_repos/$pid diff --ignore-blank-lines -b $fixed $faulted  -- "${file_name}" > $dir_original/${bid}.file_n_${fid}.dif
    		#get the stat of the diff
    		diffstat -m -t -R $dir_original/${bid}.file_n_${fid}.dif > $dir_original/${bid}.file_n_${fid}.dif.stat
    	done
    done
    echo
done
cd $current



