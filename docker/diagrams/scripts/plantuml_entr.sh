#!/usr/bin/env bash

# TODO: Allow setting `-e`, currently not possible because will stop when
# adding a new file
# set -e

cat > /tmp/.plantuml-script.sh <<"EOF2"
  FILE_PATH=$1
  EXTENSION=$2
  FNAME="${FILE_PATH%.*}" # remove .txt extension
  java -jar /home/ubuntu/files/plantuml.jar "$FILE_PATH" \
    && printf "created $FNAME.png\n"
EOF2
chmod +x /tmp/.plantuml-script.sh

_PlantUMLWatch() {
  EXTENSION=$1
  USED_DIR=${2:-/home/ubuntu/content}
  printf "looking recursively in: $USED_DIR\n"
  while true; do # when a file is added, entr will exit
    sleep 1
    find "$USED_DIR" -type f -name "*.uml.txt" | entr -d /tmp/.plantuml-script.sh /_ "$EXTENSION"
  done
}

_PlantUMLWatch
