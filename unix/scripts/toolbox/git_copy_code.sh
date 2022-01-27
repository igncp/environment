#!/usr/bin/env bash

REMOTES=$(git remote | wc -l)

if [[ $REMOTES -eq 1 ]]; then
  REMOTE=$(git remote)
else
  REMOTE=$(git remote | fzf)
fi

BRANCHES=$(git branch -a --color=always | grep -v '/HEAD\s' | sort)
BRANCHES="$BRANCHES""\n  HEAD"

BRANCH=$(printf "$BRANCHES" |
  fzf --height 100% --border -m --ansi --multi --tac --preview-window right:40% \
  --preview 'git log --oneline --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) |
  head -'$LINES | sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##; s#'"$REMOTE"'/##')

if [ -z "$BRANCH" ]; then
  exit 0
fi

cat > /tmp/get_paths.sh <<"EOF"
#!/usr/bin/env bash

ag . -l | while read line; do
  echo "$line"
  echo "$(dirname $line)"
done
EOF

SRC_PATH=$(sh /tmp/get_paths.sh | sort | uniq |
  fzf --height 100% --border -m --ansi --multi --tac --preview-window right:40%)

CMD="# git reset -- $SRC_PATH > /dev/null 2>&1 ; rm -rf $SRC_PATH ; git checkout $BRANCH -- $SRC_PATH"

echo "$CMD"
