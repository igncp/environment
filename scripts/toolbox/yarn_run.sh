#!/usr/bin/env bash

NPM_RUN=$(npm run)
echo "$NPM_RUN" > /tmp/npm-run
COMMAND=$(echo "$NPM_RUN" | grep "^  [a-z]" |
  fzf --height 100% --border -m --ansi --multi --tac --preview-window right:70% \
  --preview "echo {} | xargs -Ill grep -A 1 '^  ll$' /tmp/npm-run")

echo "yarn run $COMMAND"
