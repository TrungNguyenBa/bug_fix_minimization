#! /bin/bash
die() {
    echo $1
    return
}
if ! (ls $BFM  > /dev/null) ; then
	die "BFM not yet been set "
fi

if ! (ls $D4J_HOME  > /dev/null) ; then
	die "D4J_HOME not yet been set"
fi

if ! (ls $FL_HOME  > /dev/null); then
	die "$FL_HOME not yet been set "
fi

projects=$(ls -1 $BFM/raw_data/D4J_projects)
for p in $projects; do
	counts=$(cat $D4J_projects/framework/projects/$p/commit-db | wc -l )
	for i in $(seq 1 $count); do
		$FL_HOME/d4j_integration/get_buggy_lines.sh $p $i $FL_HOME/analysis/pipeline-scripts/buggy-lines
		$FL_HOME/d4j_integration/get_buggy_lines_original.sh $p $i $FL_HOME/analysis/pipeline-scripts/buggy-lines-original
		$FL_HOME/d4j_integration/get_buggy_lines_nocmt.sh $p $i $FL_HOME/analysis/pipeline-scripts/buggy-lines-nocmt
	done
done
