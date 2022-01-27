#!/usr/bin/env bash

BRANCH=$(git branch --color=always | grep -v '/HEAD\s' | sort |
  fzf --height 100% --border -m --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) |
  head -'$LINES | sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##')

if [ -z "$BRANCH" ]; then
  exit 0
fi

echo "# git checkout $BRANCH; git branch | grep -v $BRANCH | xargs -I{} git branch -D {}; git remote prune origin"
