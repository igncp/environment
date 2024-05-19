#!/usr/bin/env bash

set -e

provision_setup_ruby() {
  # rbenv: 您必須將其安裝在 `ruby-rbenv-install` shell 中 (在某些系統中)
  cat >>~/.shellrc <<'EOF'
if type rbenv > /dev/null 2>&1 ; then
  mkdir -p $HOME/nix-dirs/rbenv/plugins
  export RBENV_ROOT="$HOME/nix-dirs/rbenv"
  eval "$(rbenv init -)"

  if [ ! -d $HOME/nix-dirs/rbenv/plugins/rbenv-build ]; then
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/rbenv-build
  fi

  if [ ! -d $HOME/nix-dirs/rbenv_source ]; then
    git clone https://github.com/rbenv/rbenv.git ~/nix-dirs/rbenv_source
    (cd ~/nix-dirs/rbenv_source && git reset --hard ac020225c29 && rm -rf .git)
  fi
fi
EOF

  cat >>~/.shell_aliases <<'EOF'
if type rbenv > /dev/null 2>&1 ; then
  # 安裝一些 gems（如“rails”）後必需的
  alias RbenvRehash='rbenv rehash'
fi
EOF

  cat >>~/.zshrc <<'EOF'
if type rbenv > /dev/null 2>&1 ; then
  source ~/nix-dirs/rbenv_source/completions/rbenv.zsh || true
fi
EOF
}
