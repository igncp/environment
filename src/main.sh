#!/usr/bin/env bash

set -e

if [ ! -f ~/.check-files/first-run ]; then
  echo "呢個條文仲未完全執行"
  set -x
fi

. src/entry.sh

provision_main() {
  if type sudo >/dev/null 2>&1; then
    sudo echo '在開始時詢問 sudo' >/dev/null
  fi

  provision_setup_with_bash
  touch ~/.check-files/first-run

  echo "環境配置成功完成"
}

provision_main
