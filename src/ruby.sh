#!/usr/bin/env bash

set -euo pipefail

provision_setup_ruby() {
  cat >>~/.shell_aliases <<'EOF'
if type rbenv > /dev/null 2>&1 ; then
  eval "$(rbenv init - --no-rehash bash)"

  # 安裝一些 gems（如“rails”）後必需的
  alias RbenvRehash='rbenv rehash'
fi

# 在 macos 中它有 ruby 但是 v2
if type ruby > /dev/null 2>&1 && [ "$(ruby -v | sed 's|ruby ||' | head -c 1)" = "3" ]; then
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

  if [ -f "$PROVISION_CONFIG"/ruby ]; then
    add_vscode_extension "shopify.ruby-lsp"
  fi
}
