#!/usr/bin/env bash

set -e

if [ ! -f ~/.check-files/first-run ]; then
  echo "The provision hasn't been run completely yet"
  set -x
fi

. src/entry.sh

provision_main() {
  sudo echo '在開始時詢問 sudo' >/dev/null
  provision_setup_with_bash
  touch ~/.check-files/first-run

  echo "環境配置成功完成"
}

provision_main
