#!/usr/bin/env bash

# TODO: Allow setting `-e`, currently not possible because will stop when
# adding a new file
# set -e

cat > /tmp/.dot-script.sh <<"EOF2"
  FILE_PATH=$1
  EXTENSION=$2
  FNAME="${FILE_PATH%.*}" # remove .dot extension
  dot "$FILE_PATH" -T"$EXTENSION" > "$FNAME"."$EXTENSION" \
    && printf "created $FNAME."$EXTENSION"\n"
EOF2
chmod +x /tmp/.dot-script.sh

_DotRecursiveWatch() {
  EXTENSION=$1
  USED_DIR=${2:-/home/ubuntu/content}
  printf "looking recursively in: $USED_DIR\n"
  while true; do # when a file is added, entr will exit
    sleep 1
    find "$USED_DIR" -type f -name "*.dot" | entr -d /tmp/.dot-script.sh /_ "$EXTENSION"
  done
}

_DotRecursiveWatch png $@
