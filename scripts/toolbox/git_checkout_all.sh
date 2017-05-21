#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  echo "$ABSOLUTE_PATH _"
  exit 0
fi

REMOTES=$(git remote | wc -l)

if [[ $REMOTES -eq 1 ]]; then
  REMOTE=$(git remote)
else
  REMOTE=$(git remote | fzf)
fi

BRANCH=$(git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf --height 100% --border -m --ansi --multi --tac --preview-window right:70% \
  --preview 'git log --oneline --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) |
  head -'$LINES | sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##; s#'"$REMOTE"'/##')

CMD="git checkout $BRANCH"
echo "$CMD"
eval "$CMD"
