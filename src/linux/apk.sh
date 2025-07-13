#!/usr/bin/env bash

set -euo pipefail

. src/linux/gui.sh

provision_setup_linux_apk() {
  if ! type apk &>/dev/null; then
    return
  fi

  if [ -n "$(cat /etc/apk/repositories | grep '#.*comunity')" ]; then
    echo 'You should enable community repository in /etc/apk/repositories'
  fi

  cat >>~/.shell_aliases <<EOF
alias SystemUpdate='sudo apk update && sudo apk upgrade'

alias ApkInfo='apk info -v'

alias shutdown='poweroff'
EOF
}
