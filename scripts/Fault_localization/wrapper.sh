#! /bin/bash
die() {
    echo $1
    return
}
dirss=$(ls -1 ); for d in $dirss; do counts=$(ls -1 $d| wc -l); if [[ counts -gt 2 ]]; then echo "$d : count = $counts"; fi; done
current=$(pwd)
#populate the analysis scripts
source scripts_populate.sh
echo "finish populate scripts"
#moving into FL_HOME analysis scripts folder
echo "moving into $FL_HOME/analysis/pipeline-scripts/"
cd $FL_HOME/analysis/pipeline-scripts/
#clean old data
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
echo "finished cleaning up"
echo
#populate buggy line folders
echo "making buggy-lines folders"
if ! ( source buggy_lines_populate.sh ); then cd $current; die "buggy_lines_populate error" ; fi
echo
echo "finished buggy_lines_populate"
echo
projects=$(ls -1 $BFM/raw_data/D4J_projects)
#iterating through projects
for p in $projects; do
	echo "-----"
	counts=$(cat $D4J_HOME/framework/projects/$p/commit-db | wc -l)
	#iterating through bugs 	
	for i in $(seq 1 $counts); do
		echo echo "perform analysis for Project $p, Bug $i"
		#extracting one by one due to storage limit
		if ! (tar xvf $FL_HOME/real-faults-data/$p/$i/*h-killmap-files.tar.gz -C $FL_HOME/real-faults-data/ 2> /dev/null); then echo "ERROR untar killmap ($p $i)"; continue; fi
		if ! (tar xvf $FL_HOME/real-faults-data/$p/$i/*gzoltar-files.tar.gz -C $FL_HOME/real-faults-data/ 2> /dev/null); then echo "ERROR untar gzoltar ($p $i)"; continue; fi
		if ! (gunzip $FL_HOME/real-faults-data/killmaps/killmap.csv.gz 2> /dev/null) ; then echo "ERROR gunzip killmap ($p $i)"; continue; fi
		cov_dir=$FL_HOME/real-faults-data/gzoltars/$p/$i
		km_dir=$FL_HOME/real-faults-data/killmaps/$p/$i
		#perform analysis for minimized version
		if ! (source do-full-analysis $p $i developer \
						      $cov_dir/matrix $cov_dir/spectra \
						      km_dir/killmap.csv km_dir/mutants.log \
						      /tmp/scoring/$p/$i/developer \
						      scores.csv); then die "Error: do-full-analysis" ; fi
		#perform analysis for comment version
		if !(source do-full-analysis-nocmt $p $i developer \
							      cov-matrix.txt cov-spectra.txt \
							      killmap.csv mutants.log \
							      /tmp/scoring/$p/$i/developer \
							      scores.csv); then die "Error: do-full-analysis-nocmt"; fi
		#perform analysis for original version
		if !(source do-full-analysis-orignial.sh $p $i developer \
									      cov-matrix.txt cov-spectra.txt \
									      killmap.csv mutants.log \
									      /tmp/scoring/$p/$i/developer \
									      scores.csv) ; then die "Error: do-full-analysis-original"; fi
		#cleaning due to store limit
		rm -r $FL_HOME/real-faults-data/killmaps/$p/$i
		rm -r $FL_HOME/real-faults-data/gzoltars/$p/$i
		echo "Project $p, Bug $1 finish"

		echo
	done
	echo "finish analysus for $p"
	echo "-----"
	echo
done
rm -rf /tmp/scoring/
cd $current
