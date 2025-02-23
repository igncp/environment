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

  cat >>~/.shell_aliases <<"EOF"
if type flutter >/dev/null 2>&1; then
  alias FlutterBuild='flutter build'
  alias FlutterCreate='flutter create' # FlutterCreate my_app
  alias FlutterRun='flutter run'
  alias PubGet='flutter pub get'
fi
EOF

  install_nvim_package "dart-lang/dart-vim-plugin"
}
