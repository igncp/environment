#!/usr/bin/env bash

FILE=$(git ls-files |
  fzf --height 100% --border)

if [[ -z "$FILE" ]]; then exit 1; fi

echo '
_tmp_fn() {
  FILE_PATH="$1"
  LOG_NUMBER=$2
  LOGS=$(git log --format="%H" -- "$FILE_PATH");
  COMMIT=$(echo "$LOGS" | tac | sed "$LOG_NUMBER""q;d");

  git show --color $COMMIT -- "$FILE_PATH" | diff-so-fancy | less -R;

  git show "$COMMIT:$FILE_PATH" | nvim -R -c "set foldlevel=20" -;

  echo "Log number: $LOG_NUMBER / "$(echo "$LOGS" | wc -l);
};
clear && _tmp_fn '"$FILE"' 1'
