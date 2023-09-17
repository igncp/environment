#!/usr/bin/env bash

set -e

provision_setup_dart() {
  if [ ! -f $PROVISION_CONFIG/dart ]; then
    return
  fi

  cat >>~/.shellrc <<"EOF"
export PATH="$PATH:$HOME/flutter/bin"
export PATH="$PATH:$HOME/flutter/bin/cache/dart-sdk/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
EOF

  install_nvim_package "dart-lang/dart-vim-plugin"

  if ! type stagehand >/dev/null 2>&1; then
    pub global activate stagehand
  fi
}
