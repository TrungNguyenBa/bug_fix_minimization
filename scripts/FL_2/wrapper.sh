#! /bin/bash

die() {
    echo $1
    exit 1
}

if ! ( ls $D4J_HOME  > /dev/null 2> /dev/null ); then
	die "D4J_HOME does not exist"
fi

if ! ( ls $FL_HOME  > /dev/null 2> /dev/null ); then
	die "FL_HOME does not exist"
fi

run_sample=0

if [[ $1 == "sample" ]]; then
	run_sample=1
fi


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
			if [[ $p == Time ]] && [[ $bugid -lt 2800000 ]] && [[ $bugid -gt 2100000 ]] ; then
				echo "$p-$bugid does not work right now"
			elif [[ $p == Lang ]] && [[ $bugid -eq 4000000 ]] ; then
				echo "$p-$bugid does not work right now"
			else
				echo populate buggy lines $p-$bugid
				$FL_HOME/d4j_integration/get_buggy_lines.sh $p $bugid $buggylinedir
			fi
		fi
	done
	#calculate sbfl score
	
	
	
	HERE="${FL_HOME}/analysis/pipeline-scripts"
	
	PATH="$HERE:$PATH"
	if [[ $(pwd) != $HERE ]] ; then
		cd $HERE
	fi

    fulllines=""
	if [[ $run_sample == 1 ]]; then
		fulllines=$(grep "$p" $D4J_HOME/framework/projects/FL_sample_set.txt)
	else
		fulllines=$(cat $currentdir/commit-db)
	fi
	for l in $fulllines; do
		bugid=$(echo $l | cut -d ',' -f1 )
		WORKING_DIR=/tmp/scoring/$p/$bugid
		if [[ $p == Time ]] && [[ $bugid -lt 2800000 ]] && [[ $bugid -gt 2100000 ]] ; then
			echo "$p-$bugid does not work right now"
			continue
		elif [[ $p == Lang ]] && ( [[ $bugid -eq 4000000 ]]   ); then
			echo "$p-$bugid does not work right now"
			continue
		elif [[ $(grep "${p},${bugid}" ${HERE}/master_scores.csv 2> /dev/null) != "" ]]; then
			echo "$p-$bugid is already done"
			continue 
		#taking too long case
		elif [[ $p == Closure ]] && ( [[ $bugid == 11000000 ]] || [[ $bugid == 11700000 ]] || [[ $bugid == 11800000 ]] || [[ $bugid == 12900000 ]] || [[ $bugid -eq 3100000 ]]); then
			echo "$p-$bugid takes too long"
			continue 
		elif [[ $p == Math ]] && ( [[ $bugid == 600000 ]] || [[ $bugid == 1600000 ]] ||  [[ $bugid == 1700000 ]] ||  [[ $bugid == 1800000 ]]  ); then
			echo "$p-$bugid takes too long"
			continue 
		fi

		
		PROJECT=$p
		BUG=$bugid
		TEST_SUITE=developer
		if !( ls $FL_HOME/gzoltars-data/  > /dev/null 2> /dev/null	); then
			mkdir -p $FL_HOME/gzoltars-data/ 
		fi

		if !( ls $FL_HOME/gzoltars-data/gzoltars/$p/$bugid/matrix > /dev/null 2> /dev/null ) || !(ls $FL_HOME/gzoltars-data/gzoltars/$p/$bugid/spectra > /dev/null 2> /dev/null); then
			if !( ls $FL_HOME/gzoltars-data/${p}-${bugid}-developer-gzoltar-files.tar.gz > /dev/null 2> /dev/null); then
				echo "run gzoltar for $p-$bugid"
				$FL_HOME/gzoltar/run_gzoltar.sh $p $bugid $FL_HOME/gzoltars-data/ developer 
			else
				echo "extract gzoltar for $p-$bugid"
				tar xvf $FL_HOME/gzoltars-data/${p}-${bugid}-developer-gzoltar-files.tar.gz -C $FL_HOME/gzoltars-data/ 2> /dev/null
			fi

		fi

		if ( ls $FL_HOME/gzoltars-data/gzoltars/$p/$bugid/matrix > /dev/null 2> /dev/null ) && (ls $FL_HOME/gzoltars-data/gzoltars/$p/$bugid/spectra > /dev/null 2> /dev/null); then 
			if !(ls $HERE/score_log/ > /dev/null 2> /dev/null) ; then
				mkdir -p $HERE/score_log/
			fi
			
			echo "calculate score for $p-$bugid"
			COVERAGE_MATRIX=$FL_HOME/gzoltars-data/gzoltars/$p/$bugid/matrix
			STATEMENT_NAMES=$FL_HOME/gzoltars-data/gzoltars/$p/$bugid/spectra
			OUTPUT="$WORKING_DIR"/scores.csv
			mkdir -p "$WORKING_DIR"
			pushd "$WORKING_DIR" >/dev/null

			mkdir -p sbfl
			pushd sbfl >/dev/null
			if [ ! "$RESTRICTIONS_FILE" ] || python "$HERE/check-restrictions" "$RESTRICTIONS_FILE" --family sbfl; then
			  do-sbfl-analysis "${RESTRICTIONS_FILE_SUBARGS[@]}" "$PROJECT" "$BUG" "$COVERAGE_MATRIX" "$STATEMENT_NAMES" > $HERE/score_log/$PROJECT-$BUG-log
			fi
			popd >/dev/null

			popd >/dev/null

			find "$WORKING_DIR"/sbfl -name score.txt | \
			  python3 "$HERE/gather-scores-into-master-scoring-file.py" \
			    --project "$PROJECT" --bug "$BUG" --test-suite "$TEST_SUITE" \
			  > "$OUTPUT" || exit 1
			if !(ls $HERE/master_scores.csv > /dev/null 2> /dev/null); then
				head -n 1 "$WORKING_DIR"/scores.csv  > $HERE/master_scores.csv
			fi
			grep "$p,$bugid" "$WORKING_DIR"/scores.csv >>  $HERE/master_scores.csv
			
			rm -rf $WORKING_DIR 2> /dev/null
			rm -rf $FL_HOME/gzoltars-data/gzoltars/$p/$bugid/ 2> /dev/null
		fi
		
	done

done

cd $here
