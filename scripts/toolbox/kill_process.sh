#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  PID=$(ps -ef |
    sed 1d |
    fzf --height 100% --border -m --ansi --header 'sudo kill -9 SELECTION_PID' |
    awk '{print $2}')

  [[ -z "$PID" ]] && exit 0

  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  echo "$ABSOLUTE_PATH $PID"
  exit 0
fi

# --

PID="$1"

if [[ ! -z "$PID" ]]; then
  sudo kill -9 "$PID"
else
  echo "No pid found"
fi
