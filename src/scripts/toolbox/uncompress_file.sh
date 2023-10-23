#!/usr/bin/env bash

set -e

main() {
  local FILE_PATH=$(find . -type f | fzf)

  if [ -z "$FILE_PATH" ]; then
    return
  fi

  if [ -n "$(echo "$FILE_PATH" | grep -E '\.zip$' || true)" ]; then
    echo "unzip $FILE_PATH -d ."
    exit 0
  elif [ -n "$(echo "$FILE_PATH" | grep -E '\.tar.gz$' || true)" ]; then
    echo "tar xvzf $FILE_PATH -C ."
    exit 0
  fi

  echo "echo Unknown file type"
}

main
