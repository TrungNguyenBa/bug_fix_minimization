#! /bin/bash

die() {
    echo $1
    exit 1
}

if ! ( ls $D4J_HOME  > /dev/null 2> /dev/null ); then
	die "D4J_HOME does not exist"
fi


export FL_HOME=/Users/trung/Documents/Umass_rs/FL_techniques/FL-data

buggylinedir=$FL_HOME/analysis/pipeline-scripts/buggy-lines

#populate source-code-lines
here=$(pwd)

if !( ls $FL_HOME/analysis/pipeline-scripts/source-code-lines > /dev/null 2> /dev/null ); then
	echo populate source-code-lines
	cd $FL_HOME/analysis/java-parser/
	./run_java-parser.sh 
	cp -r source-code-lines $FL_HOME/analysis/pipeline-scripts/.
	cd $here
fi



for p in Closure Lang Math Time; do
	currentdir=$D4J_HOME/framework/projects/$p
	number=$(cat $currentdir/commit-db | wc -l)
	lines=$(tail -n $(( $number )) $currentdir/commit-db)
	for l in $lines; do
		bugid=$(echo $l | cut -d ',' -f1 )
		#populate buggy lines
	
		if !( ls $buggylinedir/$p-${bugid}.buggy.lines > /dev/null 2> /dev/null ) || [[ $(tail -n 1 $buggylinedir/$p-${bugid}.buggy.lines) == "" ]]; then
			echo populate buggy lines $p-$bugid
			$FL_HOME/d4j_integration/get_buggy_lines.sh $p $bugid $buggylinedir
		fi
	done


done
