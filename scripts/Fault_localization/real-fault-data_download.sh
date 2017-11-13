#! /bin/bash
die() {
    echo $1
    return
}
current=$(pwd)
if  ! (ls $FL_HOME  > /dev/null ) ; then 
	die "FL_HOME not set yet" 
fi
cd $FL_HOME/
if  (ls $FL_HOME/real-faults-data/ > /dev/null) ; then
	rm -r $FL_HOME/real-faults-data/
fi
mkdir -p $FL_HOME/real-fault-data/
projects=$(ls -1 $BFM/raw_data/D4J_projects)
for p in $projects; do
	echo "perform analysis for $p"
	echo "-----"
	counts=$(cat $D4J_HOME/framework/projects/$p/commit-db | wc -l)
	#iterating through bugs 	
	for i in $(seq 1 $counts); do
		wget --recursive --no-parent -P /tmp/ http://fault-localization.cs.washington.edu/data/$p/$i
	done
done
mv /tmp/fault-localization.cs.washington.edu $FL_HOME/real-faults-data
cd $current

