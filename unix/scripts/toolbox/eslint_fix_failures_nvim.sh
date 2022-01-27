#!/usr/bin/env bash

TARGET_ITEM=$(find . ! -path "*node_modules*" ! -path "*.git*" |
  fzf --height 100% --border --ansi --header "Please choose where to run eslint")

if [ -z "$TARGET_ITEM" ]; then
  exit 0
fi

echo "./node_modules/.bin/eslint --fix $TARGET_ITEM | grep '^/' | xargs nvim -p"
