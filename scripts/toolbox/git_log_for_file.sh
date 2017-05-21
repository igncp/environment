#!/usr/bin/env bash

FILE=$(git ls-files |
  fzf --height 100% --border)

if [[ -z "$FILE" ]]; then
  exit 1;
fi

echo 'git log --format=oneline -- '"$FILE"
