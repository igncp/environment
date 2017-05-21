#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  echo "$ABSOLUTE_PATH _"
  exit 0
fi

# --

FILE_PATH=$(git -c color.status=always status --short |
  fzf --height 100% --border  -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //')

if [[ ! -z "$FILE_PATH" ]]; then
  $EDITOR "$FILE_PATH"
else
  echo "No file selected"
fi
