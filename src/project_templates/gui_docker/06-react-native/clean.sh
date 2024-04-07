#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR"

FILES_TO_REMOVE="$(cat .gitignore)"

cd -

while read -r FILE; do
  if [ -z "$FILE" ]; then
    continue
  fi

  echo "刪除以下文件: $FILE"
  sudo rm -rf "$FILE"
done <<<"$FILES_TO_REMOVE"

echo "乾淨的腳本成功完成"
