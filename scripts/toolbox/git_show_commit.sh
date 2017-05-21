#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  echo "$ABSOLUTE_PATH _"
  exit 0
fi

COMMIT=$(git log --no-merges --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --color=always |
  fzf --height 100% --border -m  --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header "git show SELECTION             Press CTRL-S to toggle sort" \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}")

git show "$COMMIT" --color | diff-so-fancy | less -R
