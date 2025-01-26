#!/usr/bin/env bash

set -e

provision_setup_ruby() {
  ruby_cleanup_provision() {
    sudo rm -rf ~/.local/rbenv
  }

  if [ ! -f "$PROVISION_CONFIG"/ruby ]; then
    ruby_cleanup_provision
    return
  elif [ "$IS_PROVISION_UPDATE" = "1" ]; then
    ruby_cleanup_provision
  fi

  mkdir -p ~/.local
  if [ ! -d ~/.local/rbenv ]; then
    git clone https://github.com/rbenv/rbenv.git ~/.local/rbenv
    eval "$(~/.local/rbenv/bin/rbenv init -)" || true
  fi

  export RBENV_ROOT="$HOME/.local/rbenv"
  export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
  mkdir -p ~/.local/rbenv/plugins

  if [ ! -d "$RBENV_ROOT/plugins/rbenv-build" ]; then
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/rbenv-build
  fi

  if ! type ruby >/dev/null 2>&1; then
    local RUBY_VERSION=""
    local RUBY_VERSION="$(cat $PROVISION_CONFIG/ruby)"
    if [ -z "$RUBY_VERSION" ]; then
      local RUBY_VERSION="$(rbenv install -l | grep '^3\.4' || true)"
    fi
    rbenv install "$RUBY_VERSION"
    rbenv global "$RUBY_VERSION"
  fi

  cat >>~/.shellrc <<'EOF'
export RBENV_ROOT="$HOME/.local/rbenv"
export PATH="$HOME/.local/rbenv/bin:$PATH"
EOF

  cat >>~/.bashrc <<'EOF'
eval "$($HOME/.local/rbenv/bin/rbenv init - bash)"
EOF

  cat >>~/.zshrc <<'EOF'
eval "$($HOME/.local/rbenv/bin/rbenv init - zsh)"
EOF

  cat >>~/.shell_aliases <<'EOF'
if type rbenv > /dev/null 2>&1 ; then
  # 安裝一些 gems（如“rails”）後必需的
  alias RbenvRehash='rbenv rehash'
fi
EOF
}
