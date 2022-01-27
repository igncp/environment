#!/usr/bin/env bash

ITEM_TO_SEARCH=$(find . ! -path "*node_modules*" ! -path "*.git*" |
  fzf --header "Choose where to apply vidir")

if [ -z "$ITEM_TO_SEARCH" ]; then
  ITEM_TO_SEARCH="."
fi

cat >/tmp/vidir-cmds <<"EOF"
find "$1" -type f ! -path "*node_modules*" ! -path "*.git*"
find "$1" -maxdepth 1
find "$1" -maxdepth 2 -type d
echo "$1"
EOF

CMD=$(fzf </tmp/vidir-cmds)

if [ -z "$CMD" ]; then
  CMD='find "$1" -type f ! -path "*node_modules*" ! -path "*.git*'
  PREFIX="# "
else
  PREFIX=""
fi

echo "$PREFIX"'_ViDir() { '"$CMD"' | vidir -v -; } && _ViDir '"$ITEM_TO_SEARCH"
