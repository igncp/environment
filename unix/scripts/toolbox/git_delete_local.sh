#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  echo "$ABSOLUTE_PATH _"
  exit 0
fi

BRANCH=$(git branch --color=always | grep -v '/HEAD\s' | sort |
  fzf --height 100% --border -m --ansi --multi --tac --preview-window right:70% \
  --preview 'git log --oneline --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) |
  head -'$LINES | sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##')

CMD="git branch -D $BRANCH"

echo "$CMD"
echo "If you are sure press enter"
read -r _

eval "$CMD"
