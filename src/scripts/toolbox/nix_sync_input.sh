#!/usr/bin/env bash

set -e

if [ ! -f ~/.scripts/.nix_sync_list_rc ]; then
  echo "echo 您必須建立包含所有可能的目錄的文件: "~/.scripts/.nix_sync_list_rc""
  exit 1
fi

ALL_DIRS=$(cat ~/.scripts/.nix_sync_list_rc)

ALL_DIRS="$ALL_DIRS
~/development/environment/src/scripts/specific/deluge_custom_client"

if [ -z "$1" ]; then
  echo "ALL" >/tmp/nix_sync_list_rc
  echo "$ALL_DIRS" >>/tmp/nix_sync_list_rc

  SELECTED_DIRS="$(cat /tmp/nix_sync_list_rc | fzf -m)"
  IS_ALL="$(echo $SELECTED_DIRS | grep '\bALL\b' || true)"

  if [ -n "$IS_ALL" ]; then
    SELECTED_DIRS="$ALL_DIRS"
  fi

  SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
  )"

  SELECTED_DIRS=$(echo $SELECTED_DIRS | tr -d '\n')

  echo "bash $SCRIPTPATH/nix_sync_input.sh $SELECTED_DIRS"
  exit 0
fi

SELECTED_DIRS="$@"

if [ "$SELECTED_DIRS" = "ALL" ]; then
  SELECTED_DIRS=$(cat ~/.scripts/.nix_sync_list_rc)
fi

for SELECTED_DIR in $SELECTED_DIRS; do
  eval RESOLVED_PATH="$SELECTED_DIR"

  if [ ! -f "$RESOLVED_PATH"/flake.lock ]; then
    ls -lah "$RESOLVED_PATH"
    echo "flake.lock not found in $RESOLVED_PATH"
    exit 1
  fi

  INPUTS=$(nix flake metadata --json "$RESOLVED_PATH" 2>/dev/null | jq -r '.locks.nodes | keys[]' | grep -vE '(systems|root)')

  echo "$INPUTS" | while read -r INPUT; do
    ENV_INPUT=$(nix flake metadata --json ~/development/environment 2>/dev/null | jq -r '.locks.nodes."'"$INPUT"'"')

    if [ -z "$ENV_INPUT" ]; then
      continue
    fi

    if [ -n "$(find $RESOLVED_PATH -maxdepth 0 | grep 'development.environment$')" ]; then
      # 您不能在 environment 儲存庫中使用此命令
      continue
    fi

    cat $RESOLVED_PATH/flake.lock | jq '.nodes."'"$INPUT"'"'" = $ENV_INPUT"'' | sponge $RESOLVED_PATH/flake.lock
    echo "輸入 '$INPUT' 更新於 '$RESOLVED_PATH/flake.lock'"
  done

  if [ -d "$RESOLVED_PATH"/.direnv ]; then
    echo "刪除 $RESOLVED_PATH/.direnv"
    rm -rf "$RESOLVED_PATH"/.direnv
  fi

  echo ""
done
