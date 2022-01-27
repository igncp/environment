#!/usr/bin/env bash

DIR=$(find . -type d ! -path "*.git*" ! -path "*node_modules*" |
  fzf --height 100% --border -m  --ansi)

echo '
__tmp_fn() {
  FIND_OPTS="$1"
  DIR="$2";
  FILE_TITLE_COMMENT="$3";
  echo "" > /tmp/open_files_in_one;
  find "$DIR" $FIND_OPTS | while read LINE; do
    printf "$FILE_TITLE_COMMENT >>> $LINE\n\n" >> /tmp/open_files_in_one;
    cat "$LINE" >> /tmp/open_files_in_one;
    printf "\n\n\n\n\n\n\n\n" >> /tmp/open_files_in_one;
  done;
  $EDITOR /tmp/open_files_in_one;
} && __tmp_fn '"'-type f' $DIR '#'"
