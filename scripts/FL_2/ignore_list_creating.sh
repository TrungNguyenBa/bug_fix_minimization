#! /bin/bash

outfile=$1/ignore_list.csv

projectsdir=$D4J_HOME/framework/projects

for p in Closure Lang Math Time; do
	lines=$(head -n $(( $(cat $projectsdir/$p/commit-db | wc -l) / 2 )) $projectsdir/$p/commit-db)
	patchdir=$projectsdir/$p/patches
	for l in $lines; do
		bugid=$(echo $l | cut -d "," -f1)
		(ls $patchdir/${bugid}00000.src.patch  > /dev/null 2> /dev/null ) || echo "$p,$bugid" >> $outfile
		if [[ $( tail -n +5 $patchdir/${bugid}.src.patch  2> /dev/null)  == $( tail -n +5 $patchdir/${bugid}00000.src.patch  2> /dev/null) ]]; then
			echo "$p,$bugid" >> $outfile
		fi
	done
done

