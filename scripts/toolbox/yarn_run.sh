#!/usr/bin/env bash

CACHED_FILE="/tmp/$(pwd | sed 's|^.||g; s|/|-|g')-yarn-run"

if [ ! -f "$CACHED_FILE" ]; then
  NPM_RUN=$(npm run)
  echo "$NPM_RUN" > "$CACHED_FILE"
fi

COMMAND=$(grep "^  [a-z]" "$CACHED_FILE" |
  fzf --height 100% --border -m --ansi --multi --tac --preview-window right:70% \
  --preview "echo {} | xargs -Ill grep -A 1 '^  ll$' /tmp/npm-run")

if [ -z "$COMMAND" ]; then
  echo "# rm -rf $CACHED_FILE # to remove the cached file"
  exit 0
fi

echo "yarn run $COMMAND"
