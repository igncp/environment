#!/usr/bin/env bash

DIR=$(find . -type d ! -path "*.git*" ! -path "*node_modules*" | fzf --height 100% --border -m  --ansi)

echo '
__tmp_fn() {
  DIR=$1;
  find "$DIR" -type f | xargs wc -l | sort -nr | less;
} && __tmp_fn '"$DIR"
