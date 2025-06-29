#!/usr/bin/env bash

set -e

provision_setup_ruby() {
  cat >>~/.shell_aliases <<'EOF'
if type rbenv > /dev/null 2>&1 ; then
  eval "$(rbenv init - --no-rehash bash)"

  # 安裝一些 gems（如“rails”）後必需的
  alias RbenvRehash='rbenv rehash'
fi

if type ruby > /dev/null 2>&1 ; then
  if type nix-shell > /dev/null 2>&1 ; then
    if [ -z "$IN_NIX_SHELL" ] && ! type ruby-lsp > /dev/null 2>&1 ; then
      echo "安裝 ruby-lsp"
      nix-shell -p libyaml --command 'gem install ruby-lsp'
    fi
  elif ! type ruby-lsp > /dev/null 2>&1 ; then
    echo "安裝 ruby-lsp"
    gem install ruby-lsp
  fi
fi
EOF
}
