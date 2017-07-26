#!/usr/bin/env bash

git add -A . > /dev/null 2>&1

SELECTED_FILES=$(git status --porcelain | fzf --height 100% --border  -m --ansi --nth 2 --reverse --cycle \
  --preview 'git diff --color=always HEAD -- {-1}')

git reset > /dev/null 2>&1

if [ -z "$SELECTED_FILES" ]; then
  exit 0
fi

while read -r SELECTED_FILE; do
  echo "$SELECTED_FILE" | sed s/^..// | xargs -I {} git add -A {} > /dev/null 2>&1
done <<< "$SELECTED_FILES"

echo 'git commit -v'
