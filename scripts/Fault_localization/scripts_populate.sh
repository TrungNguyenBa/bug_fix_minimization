#! /bin/bash
die() {
    echo $1
    return
}
if ! (ls $FL_HOME > /dev/null 2> /dev/null); then
	die "$FL_HOME not yet been set "
fi

cp -r !(scripts_populate.sh)  $FL_HOME/analysis/pipeline-scripts/.
mv $FL_HOME/analysis/pipeline-scripts/get_buggy_lines* $FL_HOME/d4j_integration/.
