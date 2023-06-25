#!/usr/bin/env bash

REMOTES=$(git remote | wc -l)

if [[ $REMOTES -eq 1 ]]; then
  REMOTE=$(git remote)
else
  REMOTE=$(git remote | fzf)
fi

CURRENT_BRANCH=$(git branch | grep '\*' | cut -d ' ' -f2)

BRANCH=$(git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf --height 100% --border -m --ansi --multi --tac --preview-window right:40% -q "$CURRENT_BRANCH" \
  --preview 'git log --oneline --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) |
  head -'$LINES | sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##; s#'"$REMOTE"'/##')

if [ -z "$BRANCH" ]; then
  exit 0
fi

CMD="gl $(echo "$REMOTE" | cut -d' ' -f1) $BRANCH"

echo "$CMD"
