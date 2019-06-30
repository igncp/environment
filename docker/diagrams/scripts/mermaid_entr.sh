#!/usr/bin/env bash

# TODO: Allow setting `-e`, currently not possible because will stop when
# adding a new file
# set -e

cat > /tmp/.mmd-script.sh <<"EOF2"
  FILE_PATH=$1
  EXTENSION=$2
  FNAME="${FILE_PATH%.*}" # remove .mmd extension
  # if there is an error in mmdc, it will hang with a Promise rejection
  (timeout 5 mmdc -p ~/puppeteer-config.json -i "$FILE_PATH" -o "$FNAME.png" \
    && printf "created $FNAME.png\n") || (echo "error in $FILE_PATH")
EOF2
chmod +x /tmp/.mmd-script.sh

_MMDCRecursiveWatch() {
  EXTENSION=$1
  USED_DIR=${2:-/home/ubuntu/content}
  printf "looking recursively in: $USED_DIR\n"
  while true; do # when a file is added, entr will exit
    sleep 1
    find "$USED_DIR" -type f -name "*.mmd" | entr -d /tmp/.mmd-script.sh /_ "$EXTENSION"
    echo "EXITING"
  done
}

_MMDCRecursiveWatch
