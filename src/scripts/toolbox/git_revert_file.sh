#!/usr/bin/env bash

set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "不在 Git 工作樹內"
  exit 1
fi

FILE_STATUS=$(
  {
    git status --short --untracked-files=all
    git status --short --untracked-files=all |
      awk '
        {
          path = substr($0, 4)
          sub(/^.* -> /, "", path)
          directory = path
          while (sub(/\/[^\/]+$/, "", directory)) {
            if (!directories[directory]++) {
              print "DIR " directory
            }
          }
        }
      '
  } |
    fzf --height 100% --border --nth 2.. \
      --preview 'git diff --color=always -- {-1}; git diff --cached --color=always -- {-1}'
)

if [[ -z "$FILE_STATUS" ]]; then
  exit 0
fi

print_revert_command() {
  local status=$1
  local file_path=$2

  case "$status" in
  '??' | A? | ?A)
    printf ' (){ git reset --quiet -- "$1"; rm -rf -- "$1"; git status; } %q\n' \
      "$file_path"
    ;;
  D? | ?D | M? | ?M)
    printf ' (){ git reset --quiet -- "$1"; git checkout -- "$1"; git status; } %q\n' \
      "$file_path"
    ;;
  *)
    echo "無法還原不支援嘅 Git 狀態：$status"
    return 1
    ;;
  esac
}

print_revert_directory_command() {
  local directory=$1

  printf \
    ' (){ git reset --quiet -- "$1"; git checkout -- "$1"; git status; } %q\n' \
    "$directory"
}

if [[ "$FILE_STATUS" == DIR\ * ]]; then
  DIRECTORY=${FILE_STATUS:4}
  print_revert_directory_command "$DIRECTORY"
else
  print_revert_command "${FILE_STATUS:0:2}" "${FILE_STATUS:3}"
fi
