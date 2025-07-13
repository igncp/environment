#!/usr/bin/env bash

set -euo pipefail

provision_setup_nodenv() {
  cat >>~/.shellrc <<"EOF"
export PATH="$HOME/.local/nodenv/bin:$PATH"
export NODENV_ROOT="$HOME/.local/nodenv"
EOF
  cat >>~/.bashrc <<"EOF"
if [ -f ~/.local/nodenv/bin/nodenv ]; then
  eval "$(~/.local/nodenv/bin/nodenv init - bash)"
fi
EOF
  cat >>~/.zshrc <<"EOF"
if [ -f ~/.local/nodenv/bin/nodenv ]; then
  eval "$(~/.local/nodenv/bin/nodenv init - zsh)"
  source ~/.local/nodenv/completions/nodenv.zsh
fi
EOF

  nodenv_cleanup_provision() {
    sudo rm -rf ~/.local/nodenv ~/.npm-packages ~/.npm ~/.nodenv ~/nix-dirs/nodenv
  }

  if [ -f "$PROVISION_CONFIG"/no-node ]; then
    nodenv_cleanup_provision
    return
  elif [ "${IS_PROVISION_UPDATE:-0}" = "1" ]; then
    nodenv_cleanup_provision
  fi

  mkdir -p ~/.local
  if [ ! -d ~/.local/nodenv ]; then
    git clone https://github.com/nodenv/nodenv.git ~/.local/nodenv
    (cd ~/.local/nodenv && src/configure && make -C src)
    mkdir -p $HOME/.local/nodenv/plugins
  fi

  export NODENV_ROOT="$HOME/.local/nodenv"
  export PATH="$NODENV_ROOT/bin:$NODENV_ROOT/shims:$PATH"
  if [ ! -d "$NODENV_ROOT/plugins/node-build" ]; then
    git clone https://github.com/nodenv/node-build.git "$(nodenv root)"/plugins/node-build
  fi

  if [ ! -d "$NODENV_ROOT/plugins/nodenv-nvmrc" ]; then
    git clone https://github.com/ouchxp/nodenv-nvmrc.git "$(nodenv root)"/plugins/nodenv-nvmrc
  fi

  if ! type node >/dev/null 2>&1; then
    local NODE_VERSION=""
    if [ -f "$PROVISION_CONFIG"/node ]; then
      local NODE_VERSION="$(cat $PROVISION_CONFIG/node)"
    fi
    if [ -z "$NODE_VERSION" ]; then
      local NODE_VERSION="$(nodenv install -l | grep '^22' || true)"
    fi
    nodenv install "$NODE_VERSION"
    nodenv global "$NODE_VERSION"
  fi
}
