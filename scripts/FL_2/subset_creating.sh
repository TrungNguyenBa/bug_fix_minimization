#! /bin/bash

number_of_bugs=$1

(ls $D4J_HOME/framework/projects/FL_sample_set.txt > /dev/null 2> /dev/null) || touch $D4J_HOME/framework/projects/FL_sample_set.txt

for p in Closure Lang Math Time; do
	head -n $(( $(cat $D4J_HOME/framework/projects/$p/commit-db | wc -l) / 2 )) $D4J_HOME/framework/projects/$p/commit-db | sed -e "s/$/,$p/" >> $D4J_HOME/framework/projects/FL_temp.txt
done

gshuf -n $number_of_bugs $D4J_HOME/framework/projects/FL_temp.txt >  $D4J_HOME/framework/projects/FL_sample_set.txt

lines=$(cat $D4J_HOME/framework/projects/FL_sample_set.txt)

for l in $lines; do
	echo $l | awk -F ',' '{print $1"00000,,"$2""$3","$4}' >> $D4J_HOME/framework/projects/FL_sample_set.txt
done

rm $D4J_HOME/framework/projects/FL_temp.txt > /dev/null 2> /dev/null





