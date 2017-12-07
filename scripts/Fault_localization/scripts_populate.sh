#! /bin/bash
die() {
    echo $1
    exit 1
}
shopt -s extglob
if ! (ls $FL_HOME > /dev/null 2> /dev/null); then
	die "$FL_HOME not yet been set "
fi
cp run_java-parser_original.sh _run_java-parser_original.sh $FL_HOME/analysis/java-parser/.
cp run_gzoltar_original.sh $FL_HOME/gzoltar/.
cp !(scripts_populate.sh | wrapper.sh | run_java-parser_original.sh | _run_java-parser_original.sh | run_gzoltar_original.sh)  $FL_HOME/analysis/pipeline-scripts/.
mv $FL_HOME/analysis/pipeline-scripts/get_buggy_lines* $FL_HOME/d4j_integration/.
