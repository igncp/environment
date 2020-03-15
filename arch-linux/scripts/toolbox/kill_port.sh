#!/usr/bin/env bash

# requires net-tools

PID=$(netstat -ltnp 2>&1 |
  grep tcp |
  awk '{ print $4" "$7; }' |
  sed 's|0.0.0.0:||' |
  grep -v '\-$' |
  fzf --height 100% --border -m --ansi --header 'sudo kill -9 SELECTION_PID' |
  awk '{print $2}' |
  grep -o '^[0-9]*'
)

[[ -z "$PID" ]] && exit 0

echo "sudo kill -9 $PID"
