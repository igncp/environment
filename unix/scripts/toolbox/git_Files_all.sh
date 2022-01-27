#!/usr/bin/env bash

# This file has capital F for easy search

REMOTES=$(git remote | wc -l)

if [[ $REMOTES -eq 1 ]]; then
  REMOTE=$(git remote)
else
  REMOTE=$(git remote | fzf)
fi

BRANCH=$(git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf --height 100% --border -m --ansi --multi --tac --preview-window right:40% \
  --preview 'git log --oneline --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) |
  head -'$LINES | sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##; s#'"$REMOTE"'/##')

CMD='Fn() { git diff $1 --name-status | grep -E "$2" | '"sed 's|^[ADM]"'\t'"||' | xargs -I '{}' realpath --relative-to=. "'$(git rev-parse --show-toplevel)'"/'{}'; } && Fn '$BRANCH' '^.'"

echo "$CMD"
