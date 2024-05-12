#!/usr/bin/env bash

set -e

provision_setup_nodenv() {
  cat >>~/.shellrc <<"EOF"
if type nodenv > /dev/null 2>&1 ; then
  mkdir -p $HOME/nix-dirs/nodenv/plugins
  export NODENV_ROOT="$HOME/nix-dirs/nodenv"
  eval "$(nodenv init -)"
  if [ ! -d $HOME/nix-dirs/nodenv/plugins/node-build ]; then
    git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
  fi

  # 在 NixOS 中修復二進位檔案的範例
  # patchelf  ~/nix-dirs/nodenv/versions/18.20.2/bin/node --add-rpath $LD_LIBRARY_PATH_VAL
fi
EOF
}
