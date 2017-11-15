#!/bin/bash
die() {
    echo $1
    exit 1
}
[ "$D4J_HOME" != "" ] || die "D4J_HOME is not set!"
[ "$BFM" != "" ] || die "BFM is not set!"
clean=$1
projects=$2
if [ projects == "" ] || [ projects == "ALL" ]; then
    projects=(Closure Lang Math Time)
fi

current=$(pwd)
echo "living $current"
echo "moving to $BFM"

cd $BFM
for pid in $projects; do
    dir_project="$D4J_HOME/framework/projects/$pid"
    dir_patches="$dir_project/patches"
    dir_original="raw_data/D4J_projects/$pid/remove_comment_patches"
    dir_modified="raw_data/D4J_projects/$pid/raw_modified_files"
    if [[ $clean == "--clean" ]]; then rm -rf $dir_original $dir_modified > /dev/null 2> /dev/null; fi
    cmake -E make_directory $dir_original
    cmake -E make_directory $dir_modified
    echo directory is $dir_original
    # Determine the number of bugs for this project
    num_bugs=$(cat $dir_project/commit-db | wc -l)
    # Iterate over all bugs for this project
    echo "checking project $pid ($num_bugs bugs)"
    for bid in $(seq 1 $num_bugs); do
    	#get the line
    	echo $dir_project/commit-db
    	defects4j checkout -p ${pid} -v ${bid}b -w /tmp/${pid}_${bid}_buggy
        src_dir=$(grep "d4j.dir.src.classes=" /tmp/${pid}_${bid}_buggy/defects4j.build.properties | cut -f2 -d'=')
        src_dir=$src_dir/
        #specific src_dir for bug 22-27 of Time
        if [[ $pid == "Time" ]]; then
            if [ $bid == "22" ] || [ $bid == "23" ] || [ $bid == "24" ] || [ $bid == "25" ] || [ $bid == "26" ] || [ $bid == "27" ]; then
                src_dir="JodaTime/"$src_dir
            fi
        fi
    	line=$(head -${bid} $dir_project/commit-db | tail -1 )
    	#splitting the line into string array
    	IFS=$',' read -r -a array <<< "$line"
    	#get the faulted version from the array
    	faulted=${array[1]}
    	fixed=${array[2]}
    	echo "bug $bid:"
    	echo "faulted version hash: $faulted"
    	echo "fixed version hash: $fixed"
    	#get the number of file changes
    	git -C /tmp/${pid}_${bid}_buggy whatchanged -1 $fixed $faulted  --pretty=format:'%h : %s' > $dir_original/${bid}.changed_files_list.txt
    	num_files=$(cat $dir_original/${bid}.changed_files_list.txt | wc -l)
    	#iterate through the file
    	for fid in $(seq 2 $num_files); do
    		file_line=$(head -${fid} $dir_original/${bid}.changed_files_list.txt | tail -1 )
    		IFS=$' |\t|\\' read -r -a chunks <<< "$file_line"
    		echo file_line is $file_line
            file_name=${chunks[${#chunks[@]}-1]}
            if [[ $file_name == *".java" ]]; then
                IFS=$'/' read -r -a fchunks <<< "$file_name"
                #check if the file is from test folder
                istest0=${fchunks[0]}
                istest1=${fchunks[1]}
                istest2=${fchunks[2]}
                echo $istest0 $istest1 $istest2
                if [ $istest0 != "test" ] && [ $istest1 != "test" ] && [ $istest2 != "test" ]; then
            		echo file_name is $file_name
                    #get the faulted file
                    git -C /tmp/${pid}_${bid}_buggy checkout  $faulted  -- "${file_name}"
                    file_name_base=$( echo ${file_name#$src_dir} | tr '/' '.')
                    echo file_name_base is $file_name_base
                    cp /tmp/${pid}_${bid}_buggy/${file_name} $dir_modified/${bid}_${file_name_base}_faulted
                    #get the fixed file
                    git -C /tmp/${pid}_${bid}_buggy checkout  $fixed  -- "${file_name}" 
                    cp /tmp/${pid}_${bid}_buggy/${file_name} $dir_modified/${bid}_${file_name_base}_fixed
                    #removing the comments and white space from both version
                    python $BFM/scripts/remove_comment.py $dir_modified/${bid}_${file_name_base}_faulted 
                    python $BFM/scripts/remove_comment.py $dir_modified/${bid}_${file_name_base}_fixed
                    #get the diff from both file
                    diff -w -b -B $dir_modified/${bid}_${file_name_base}_fixed_nospcm_ $dir_modified/${bid}_${file_name_base}_faulted_nospcm_ > $dir_original/${bid}.file_n_${fid}.dif
            		#get the stat of the diff
            		diffstat -m -t -R $dir_original/${bid}.file_n_${fid}.dif > $dir_original/${bid}.file_n_${fid}.dif.stat
    	        fi
            fi
        done
    	rm -rf /tmp/${pid}_${bid}_buggy
    done
done
cd $current



