#!/usr/bin/env bash

set -euo pipefail

# https://www.jetbrains.com/idea/download/
# https://sookocheff.com/post/vim/neovim-java-ide/
# 檢查 vscode.md 筆記

provision_setup_java() {
  if [ ! -f "$PROVISION_CONFIG"/java ]; then
    return
  fi

  if ! type nix >/dev/null; then
    JAVA_VERSION=$(cat "$PROVISION_CONFIG"/java)

    if [ -z "$JAVA_VERSION" ]; then
      JAVA_VERSION=24
    fi

    brew install openjdk@$JAVA_VERSION
  fi

  if [ "$IS_NIXOS" = "1" ]; then
    cat >>~/.shellrc <<'EOF'
export JAVA_HOME=/run/current-system/sw/lib/openjdk/
EOF
    set_vscode_setting_if_missing "java.jdt.ls.java.home" '"/run/current-system/sw/lib/openjdk"'
  fi
}
