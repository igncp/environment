#!/usr/bin/env bash

cd $(git rev-parse --show-toplevel)

git reset > /dev/null 2>&1

# if it gets the status files after `git add`, some of the lines will be of the
# form: M previous-file -> new-file
STATUS_FILES="$(git status --porcelain)"

git add -A . > /dev/null 2>&1

SELECTED_FILES=$(echo "$STATUS_FILES" | \
  fzf --height 100% --border  -m --ansi --nth 2 --reverse --cycle \
    --preview 'git diff --color=always HEAD -- {-1}')

git reset > /dev/null 2>&1

if [ -z "$SELECTED_FILES" ]; then
  exit 0
fi

while read -r SELECTED_FILE; do
  echo "$SELECTED_FILE" | sed s/^..// | xargs -I {} git add -A {} > /dev/null 2>&1
done <<< "$SELECTED_FILES"

echo 'git commit -v'
