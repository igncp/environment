#!/usr/bin/env bash

set -e

if [ ! -f ~/.check-files/first-run ]; then
  echo "呢個條文仲未完全執行"
  set -x
fi

PROVISION_CONFIG=~/development/environment/project/.config

. src/entry.sh
. src/entry_minimal.sh

provision_main() {
  if [ -f "$PROVISION_CONFIG"/minimal ]; then
    provision_setup_minimal
  else
    if type sudo >/dev/null 2>&1; then
      sudo echo '在開始時詢問 sudo' >/dev/null
    fi

    provision_setup_with_bash
  fi

  mkdir -p ~/.check-files
  touch ~/.check-files/first-run

  echo "環境配置成功完成"
}

provision_main
