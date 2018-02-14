#!/bin/bash
current=$(pwd)
die() {
    echo $1
    cd $current
    exit 1 
}
bl=0
sl=0
if [[ $# -gt 2 ]]; then die "Usage: $0 (--nobl) (--nosl)"; fi
if [[ $1 == "--nobl" ]]; then bl=1; fi
if [[ $2 == "--nosl" ]]; then sl=1; fi

#populate the analysis scripts
./scripts_populate.sh
echo "finish populate scripts"
echo 
if [[ sl -eq 0 ]]; then 
	echo "moving into $FL_HOME/analysis/java-parser"
	cd $FL_HOME/analysis/java-parser
	if (ls source-code-lines-original > /dev/null 2>/dev/null) ; then
		rm -rf source-code-lines-original
	fi
	if ! ( ./run_java-parser_original.sh ) ; then cd $current; die "java-parse failed"; fi
	cp -r source-code-lines-original $FL_HOME/analysis/pipeline-scripts/.
fi
#moving into FL_HOME analysis scripts folder
echo "moving into $FL_HOME/analysis/pipeline-scripts/"
cd $FL_HOME/analysis/pipeline-scripts/
#clean old data


if (ls $FL_HOME/real-faults-data/killmaps > /dev/null 2> /dev/null); then rm -r $FL_HOME/real-faults-data/killmaps; fi
if (ls $FL_HOME/real-faults-data/gzoltars > /dev/null 2> /dev/null); then rm -r $FL_HOME/real-faults-data/gzoltars; fi
if [[ bl -eq 0 ]]; then 
	if (ls Scores > /dev/null 2> /dev/null); then rm -r Scores;fi
	if (ls buggy-lines > /dev/null 2> /dev/null ); then 
		if (ls buggy-lines-backup > /dev/null 2> /dev/null); then 
			rm -r buggy-lines 
		else 
			mv buggy-lines buggy-lines-backup 
		fi
	fi

	if (ls buggy-lines-original > /dev/null 2> /dev/null); then rm -r buggy-lines-original; fi
	
	if (ls buggy-lines-nocmt > /dev/null 2> /dev/null); then rm -r buggy-lines-nocmt; fi
	
	echo 
	echo "finished buggy cleaning up"
	echo
	#populate buggy line folders
	echo "making buggy-lines folders"	
	if ! ( ./buggy_lines_populate.sh ); then cd $current; die "buggy_lines_populate error" ; fi
	echo
	echo "finished buggy_lines_populate"
	echo
fi


projects=$(ls -1 $BFM/raw_data/D4J_projects)
mkdir Scores
mkdir Scores/minimized  Scores/original Scores/nocmt
#iterating through projects
for p in $projects; do
	# if [[ $p == "Closure" ]]; then 
	# 	echo "Skip"
	# 	continue
	# fi

	echo "-----"
	counts=$(cat $D4J_HOME/framework/projects/$p/commit-db | wc -l)

	ifirst=1
	# if [[ $p == "Closure" ]]; then
	# 	ifirst=59
	# fi
	# #iterating through bugs 	
	# if [[ $counts -gt 60 ]]; then
	# 	counts=60
	# fi

	for i in $(seq $ifirst $counts); do
		echo "perform analysis for Project $p, Bug $i"
		#extracting one by one due to storage limit
		#if ! (tar xvf $FL_HOME/real-faults-data/data/$p/$i/*h-killmap-files.tar.gz -C $FL_HOME/real-faults-data/ 2> /dev/null); then echo "ERROR untar killmap ($p $i)"; continue; fi

		if ! (tar xvf $FL_HOME/real-faults-data/data/$p/$i/*gzoltar-files.tar.gz -C $FL_HOME/real-faults-data/ 2> /dev/null); then 
			echo "ERROR untar gzoltar ($p $i)"
			echo "Re-do gzoltar "  
			$FL_HOME/gzoltar/run_gzoltar.sh $p $i $FL_HOME/real-faults-data/ developer
		fi

		#run gzoltar for non-minimized version
		if ! (ls $FL_HOME/real-faults-data/gzoltars-original/gzoltars/$p/$i > /dev/null 2> /dev/null);then 
			$FL_HOME/gzoltar/run_gzoltar_original.sh $p $i $FL_HOME/real-faults-data/gzoltars-original/ developer
		fi
		#if ! (gunzip $FL_HOME/real-faults-data/killmaps/$p/$i/killmap.csv.gz 2> /dev/null) ; then echo "ERROR gunzip killmap ($p $i)"; continue; fi
		if !(ls $FL_HOME/real-faults-data/gzoltars-original/gzoltars/$p/$i/matrix > /dev/null 2> /dev/null) || !(ls $FL_HOME/real-faults-data/gzoltars-original/gzoltars/$p/$i/spectra > /dev/null 2> /dev/null); then
			echo "ERROR $FL_HOME/real-faults-data/gzoltars-original/gzoltars/$p/$i/matrix or $FL_HOME/real-faults-data/gzoltars-original/gzoltars/$p/$i/spectra does not exist"
			continue
		fi


		cov_dir=$FL_HOME/real-faults-data/gzoltars/$p/$i
		km_dir=$FL_HOME/real-faults-data/killmaps/$p/$i

		#create empty files for km_dir, just to bypass do-full-analysis checking
		if ! (ls $km_dir > /dev/null 2> /dev/null) ; then
			mkdir -p $km_dir
			touch $km_dir/killmap.csv
			touch $km_dir/mutants.log 
		fi
		
# create candidates files 
		./create_candidates.sh $p $i buggy-lines
		./create_candidates.sh $p $i buggy-lines-original

		#perform analysis for minimized version
		echo "minimized version"
		if ! (./do-full-analysis $p $i developer \
						      $cov_dir/matrix $cov_dir/spectra \
						      $km_dir/killmap.csv $km_dir/mutants.log \
						      /tmp/scoring/$p/$i/developer \
						      $FL_HOME/analysis/pipeline-scripts/Scores/minimized/scores.csv  > /dev/null 2> /dev/null); then die "Error: do-full-analysis" ; fi
		if ! (ls $FL_HOME/analysis/pipeline-scripts/Scores/minimized/master_scores.csv > /dev/null 2> /dev/null); then 
			cp  $FL_HOME/analysis/pipeline-scripts/Scores/minimized/scores.csv   $FL_HOME/analysis/pipeline-scripts/Scores/minimized/master_scores.csv
		else
			cnts=$(cat $FL_HOME/analysis/pipeline-scripts/Scores/minimized/scores.csv | wc -l)
			(( cnts-- ))
			(tail -${cnts} $FL_HOME/analysis/pipeline-scripts/Scores/minimized/scores.csv) >> $FL_HOME/analysis/pipeline-scripts/Scores/minimized/master_scores.csv
		fi
		# echo
		# #perform analysis for comment version
		# echo "no comment version"
		# if ! (./do-full-analysis-nocmt $p $i developer \
		# 					      $cov_dir/matrix $cov_dir/spectra \
		# 				      	  $km_dir/killmap.csv $km_dir/mutants.log \
		# 					      /tmp/scoring/$p/$i/developer \
		# 					      $FL_HOME/analysis/pipeline-scripts/Scores/nocmt/scores.csv > /dev/null) ; then die "Error: do-full-analysis-nocmt"; fi
		# if ! (ls $FL_HOME/analysis/pipeline-scripts/Scores/nocmt/master_scores.csv > /dev/null 2> /dev/null); then 
		# 	cp  $FL_HOME/analysis/pipeline-scripts/Scores/nocmt/scores.csv   $FL_HOME/analysis/pipeline-scripts/Scores/nocmt/master_scores.csv
		# else
		# 	cnts=$(cat $FL_HOME/analysis/pipeline-scripts/Scores/nocmt/scores.csv | wc -l)
		# 	(( cnts-- ))
		# 	tail -${cnts} $FL_HOME/analysis/pipeline-scripts/Scores/nocmt/scores.csv >> $FL_HOME/analysis/pipeline-scripts/Scores/nocmt/master_scores.csv
		# fi
		#perform analysis for original version
		echo
		echo "original version"
		cov_dir=$FL_HOME/real-faults-data/gzoltars-original/gzoltars/$p/$i
		echo $cov_dir
		if ! (./do-full-analysis-original $p $i developer \
									      $cov_dir/matrix $cov_dir/spectra \
						      			  $km_dir/killmap.csv $km_dir/mutants.log \
									      /tmp/scoring/$p/$i/developer \
									      $FL_HOME/analysis/pipeline-scripts/Scores/original/scores.csv > /dev/null 2> /dev/null )  ; then die "Error: do-full-analysis-original"; fi
		if ! (ls $FL_HOME/analysis/pipeline-scripts/Scores/original/master_scores.csv > /dev/null 2> /dev/null); then 
			cp  $FL_HOME/analysis/pipeline-scripts/Scores/original/scores.csv   $FL_HOME/analysis/pipeline-scripts/Scores/original/master_scores.csv
		else
			cnts=$(cat $FL_HOME/analysis/pipeline-scripts/Scores/original/scores.csv | wc -l)
			(( cnts-- ))
			tail -${cnts} $FL_HOME/analysis/pipeline-scripts/Scores/original/scores.csv >> $FL_HOME/analysis/pipeline-scripts/Scores/original/master_scores.csv
		fi
		#cleaning due to store limit
		rm -r $FL_HOME/real-faults-data/killmaps/$p/$i
		rm -r $FL_HOME/real-faults-data/gzoltars/$p/$i
		rm -r $FL_HOME/real-faults-data/gzoltars-original/gzoltars/$p/$i
		echo "Project $p, Bug $i finish"
		#die "no reason"
		echo
	done
	echo "finish analysis for $p"
	echo "-----"
	echo
done
rm -rf /tmp/scoring/
cd $current
