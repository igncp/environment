#!/usr/bin/env bash

set -e

provision_setup_ruby() {
  cat >>~/.shell_aliases <<'EOF'
if type rbenv > /dev/null 2>&1 ; then
  # 安裝一些 gems（如“rails”）後必需的
  alias RbenvRehash='rbenv rehash'
fi
EOF
}
