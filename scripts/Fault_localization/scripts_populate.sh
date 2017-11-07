#! /bin/bash

if [! ls $FL_HOME]; then
	die "$FL_HOME not yet been set "
fi

cp -r !(scripts_populate.sh)  $FL_HOME/analysis/pipeline-scripts/.