#! /bin/bash

die() {
    echo $1
    exit 1
}

if ! ( ls $D4J_HOME  > /dev/null 2> /dev/null ); then
	die "D4J_HOME does not exist"
fi

projectsdir=$D4J_HOME/framework/projects 

#populate non-minimized commits	
for p in Closure Lang Math Time; do
	# check if the commit-db file has been populated
	srcfd=""
	testfd=""
	# if [[ $p == "Closure" ]] ; then
	# 	srcfd="src"
	# 	testfd="test"
	# else
	# 	srcfd="src/main/java"
	# 	if [[ $p == "Time" ]]; then
	# 		testfd="src/test/java"
	# 	else
	# 		testfd="src/test"
	# 	fi
	# fi

	currentdir=$projectsdir/$p
	checktmp=$(grep "100000," $currentdir/commit-db )
	line=""
	if [[ $checktmp == "" ]] ; then
		echo popuplate commit-db 
		#popuplate the commit-db
		lines=$(cat $currentdir/commit-db)
		for l in $lines; do
			bugid=$(echo $l | cut -d ',' -f1 )
			hashbf=$(echo $l | cut -d ',' -f2,3 )
			echo "${bugid}00000,${hashbf}" >> $currentdir/commit-db
		done
	else 
		bugnb=$(cat $currentdir/commit-db | wc -l)
		lines=$(head -n $(( $bugnb / 2 )) $currentdir/commit-db)

	fi

	# check if the pathches folder and modify classes folder have been populated
	
	
	for l in $lines; do
		bugid=$(echo $l | cut -d ',' -f1 )
		hashb=$(echo $l | cut -d ',' -f2 )
		hashf=$(echo $l | cut -d ',' -f3 )
		
		if !( ls $currentdir/modified_classes/${bugid}00000.*  > /dev/null 2> /dev/null  ) || [[ $(tail -1 $currentdir/modified_classes/${bugid}00000.src) == "" ]]; then
			echo populate modify classes folder $p-$bugid
			tempdir=/tmp/$p-$bugid
			if ! (ls $tempdir > /dev/null 2> /dev/null ); then 
				$D4J_HOME/framework/bin/defects4j checkout -p $p -v ${bugid}b -w $tempdir
			fi
			srcfd=$(grep "d4j.dir.src.classes=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			testfd=$(grep "d4j.dir.src.tests=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			#populate modified_class
			srcfd_t=$(echo $srcfd/ | sed -e "s/\//\\\\\\//g")
			git -C $tempdir diff-tree --no-commit-id --name-only -r $hashf $hashb --  $srcfd | sed -e "s/${srcfd_t}//" -e "s/.java$//g" | tr '/' '.' > $currentdir/modified_classes/${bugid}00000.src
			if [[ $(tail -1 $currentdir/modified_classes/${bugid}00000.src) == "" ]]; then
				echo $p-$bugid modified_classes file is empty
				rm $currentdir/modified_classes/${bugid}00000.src
			fi
		fi
		#cat $currentdir/modified_classes/${bugid}00000.src
		#populate patches
		if ! ( ls $currentdir/patches/${bugid}00000.src.patch  > /dev/null 2> /dev/null  ) || [[ $(tail -1 $currentdir/patches/${bugid}00000.src.patch) == "" ]]; then
			echo populate pathches folder $p-$bugid
			tempdir=/tmp/$p-$bugid
			if ! (ls $tempdir > /dev/null 2> /dev/null ); then 
				$D4J_HOME/framework/bin/defects4j checkout -p $p -v ${bugid}b -w $tempdir
			fi
			srcfd=$(grep "d4j.dir.src.classes=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			testfd=$(grep "d4j.dir.src.tests=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			git -C $tempdir diff  $hashf $hashb -- $srcfd > $currentdir/patches/${bugid}00000.src.patch
			if [[ $(tail -n 1 $currentdir/patches/${bugid}00000.src.patch) == "" ]]; then
				echo $p ${bugid}00000.src.patch is empty
				rm $currentdir/patches/${bugid}00000.src.patch
			fi
		fi

		if ! ( ls $currentdir/patches/${bugid}00000.test.patch  > /dev/null 2> /dev/null  ) || [[ $(tail -1 $currentdir/patches/${bugid}00000.test.patch) == "" ]]; then
			echo populate pathches folder $p-$bugid
			tempdir=/tmp/$p-$bugid
			if ! (ls $tempdir > /dev/null 2> /dev/null ); then 
				$D4J_HOME/framework/bin/defects4j checkout -p $p -v ${bugid}b -w $tempdir
			fi
			srcfd=$(grep "d4j.dir.src.classes=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			testfd=$(grep "d4j.dir.src.tests=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			git -C $tempdir diff  $hashf $hashb -- $testfd > $currentdir/patches/${bugid}00000.test.patch
			if [[ $(tail -n 1 $currentdir/patches/${bugid}00000.test.patch) == "" ]]; then
				echo $p ${bugid}00000.test.patch is empty
				rm $currentdir/patches/${bugid}00000.test.patch
			fi
		fi
		
	done
	

	#check if the loaded classes, relevant_tests have been populated 
	if ! ( ls $currentdir/loaded_classes/100000.*  > /dev/null 2> /dev/null  ) || !( ls $currentdir/relevant_tests/100000*  > /dev/null 2> /dev/null  ); then 
		echo populate loaded classes, relevant_tests 
		for l in $lines; do
			bugid=$(echo $l | cut -d ',' -f1 )
			hashb=$(echo $l | cut -d ',' -f2 )
			hashf=$(echo $l | cut -d ',' -f3 )
			tempdir=/tmp/$p-$bugid
			if ! (ls $tempdir > /dev/null 2> /dev/null ); then 
				$D4J_HOME/framework/bin/defects4j checkout -p $p -v ${bugid}b -w $tempdir
			fi
			srcfd=$(grep "d4j.dir.src.classes=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			testfd=$(grep "d4j.dir.src.tests=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			#populate relevant_tests with symlink
			ln -s $currentdir/relevant_tests/${bugid} $currentdir/relevant_tests/${bugid}00000
			
			#populate loaded_classes with symlink
			ln -s $currentdir/loaded_classes/${bugid}.src $currentdir/loaded_classes/${bugid}00000.src
			ln -s $currentdir/loaded_classes/${bugid}.test $currentdir/loaded_classes/${bugid}00000.test
		done 
	fi

	#check if the trigger_tests folder has been populated
	export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)
	for l in $lines; do
		bugid=$(echo $l | cut -d ',' -f1 )
		hashb=$(echo $l | cut -d ',' -f2 )
		hashf=$(echo $l | cut -d ',' -f3 )
		
		#populate trigger_tests
		if !( ls $currentdir/trigger_tests/${bugid}00000  > /dev/null 2> /dev/null ) ; then 
			echo populate trigger_tests for $p-$bugid
			tempdir=/tmp/$p-$bugid
			if ! (ls $tempdir > /dev/null 2> /dev/null ); then 
				$D4J_HOME/framework/bin/defects4j checkout -p $p -v ${bugid}b -w $tempdir
			fi
			srcfd=$(grep "d4j.dir.src.classes=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			testfd=$(grep "d4j.dir.src.tests=" $tempdir/defects4j.build.properties | cut -f2 -d'=')
			git -C $tempdir checkout $hashb -- $srcfd  $testfd
			$D4J_HOME/framework/bin/defects4j test -w $tempdir -r && cp $tempdir/failing_tests $currentdir/trigger_tests/${bugid}00000
		fi
	done
	
	rm -rf /tmp/$p-*
done



