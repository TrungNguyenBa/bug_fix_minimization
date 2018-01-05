#/bin/bash

PID=$1
BID=$2
Folder=$3

buggyline=$3/$1-$2.buggy.lines
candidates=$3/$1-$2.candidates

rm $candidates 2> /dev/null
FOM_lines=$(grep --text "FAULT_OF_OMISSION"  "$buggyline" )


for line in $FOM_lines; do
	echo $line 
	filename=$(echo $line | cut -f1 -d "#")
	linenumber=$(echo $line | cut -f2 -d "#")
	linenumberbefore=$(( linenumber-1 ))
	echo "${filename}#$linenumber,${filename}#$linenumber" >> $candidates
	echo "${filename}#$linenumber,${filename}#$linenumberbefore" >> $candidates
done




