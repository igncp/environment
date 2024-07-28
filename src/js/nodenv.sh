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

  if [ ! -d $HOME/nix-dirs/nodenv/plugins/nodenv-nvmrc ]; then
    git clone https://github.com/ouchxp/nodenv-nvmrc.git $(nodenv root)/plugins/nodenv-nvmrc
  fi

  if [ ! -d $HOME/nix-dirs/nodenv_source ]; then
    git clone https://github.com/nodenv/nodenv.git $HOME/nix-dirs/nodenv_source
    (cd ~/nix-dirs/nodenv_source && git reset --hard 0b099181753 && rm -rf .git)
  fi

  # 在 NixOS 中修復二進位檔案的範例
  # patchelf  ~/nix-dirs/nodenv/versions/18.20.2/bin/node --add-rpath $LD_LIBRARY_PATH_VAL
fi
EOF

  cat >>~/.zshrc <<"EOF"
if type nodenv > /dev/null 2>&1 ; then
  source ~/nix-dirs/nodenv_source/completions/nodenv.zsh
fi
EOF
}
