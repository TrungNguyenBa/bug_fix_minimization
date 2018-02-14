#! /bin/bash
patch -p0 -i $1 -o /tmp/tempfile
if [[ $(cat /tmp/tempfile) == "" ]]; then	
	exit 1
fi
cp /tmp/tempfile  $2
rm /tmp/tempfile
