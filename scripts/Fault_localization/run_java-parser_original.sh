#!/usr/bin/env bash

PWD=`pwd`

#
# Print error message and exit
#
die() {
  echo $1
  exit 1
}

# Check whether D4J_HOME is set
[ "$D4J_HOME" != "" ] || die "D4J_HOME is not set!"

## compile utility
mvn clean package || die "Compilation of the java-parser failed!"

JAVA_PARSER_JAR="$PWD/target/java-parser-0.0.1-SNAPSHOT-jar-with-dependencies.jar"
# Check whether JAVA_PARSER_JAR is set and exists
if [ ! -f "$JAVA_PARSER_JAR" ]; then
  die "There is no $JAVA_PARSER_JAR file"
fi

OUTPUT_DIR="$PWD/source-code-lines-original"
mkdir -p $OUTPUT_DIR

for pid in Closure Lang Math Time; do

  # defects4 project directory
  dir_project="$D4J_HOME/framework/projects/$pid"
  # determine the number of bugs for this project
  bids=$(cat $dir_project/commit-db | wc -l)

  # Iterate over all bugs (real and artificial) for this project
  for bid in $bids; do
    echo "Project $pid-${bid} ..."
    qsub "$PWD/_run_java-parser.sh" $pid $bid $OUTPUT_DIR
  done
done

# Compress data
#tar -cvzf "$PWD/source-code-lines.tar.gz" "source-code-lines"
# Put data in place
#mv -f "$PWD/source-code-lines.tar.gz" "$PWD/../pipeline-scripts/"

echo "DONE!"

# EOF

