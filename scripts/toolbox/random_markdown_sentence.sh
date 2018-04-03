#!/usr/bin/env bash

DIR=$(find . -type d ! -path "*.git*" ! -path "*node_modules*" | fzf --height 100% --border -m  --ansi)

echo $'
__tmp_fn() {
  DOCS_FILES=$(eval "find "$3" "$1" -type f -name \'*.md\' ! -path \'*node_modules*\' ! -path \'*LICENSE*\'");
  ALL_LINES="";
  for DOC_FILE in $(echo "$DOCS_FILES"); do
    NEW_LINE=$(cat "$DOC_FILE" |
      sed \'/```/,/```/d\' |
      grep -E \'^[a-zA-Z0-9-]\' |
      grep -vE \'^-[ ]+\[\' |
      grep -vE \'^[#<]\' |
      grep -vE \'^[ ]+\|\' |
      sed -E "s|^|$DOC_FILE: |");
    ALL_LINES=$(echo "$ALL_LINES"; echo "$NEW_LINE");
  done;
  RANDOM_LINE=$(echo "$ALL_LINES" |
    grep \'.\' |
    shuf -n $2 |
    sed \'s/^/\\n\\n/\' |
    sed \'s/: /:\\n\\n/\' |
    fold -w 80 -s);

  clear;

  sleep 0.1;

  echo "$RANDOM_LINE";
} && __tmp_fn ' $'\'! -path "*foobar*"\'' 1 "$DIR"
