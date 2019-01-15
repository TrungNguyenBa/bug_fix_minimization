#! /bin/bash
patch -p0 -i $1 -o /tmp/tempfile 
echo "hey"
if [[ $(cat /tmp/tempfile) == "" ]]; then	
	echo "tempfile is empty"
	exit 1
fi
cp /tmp/tempfile  $2
rm /tmp/tempfile
