#!/usr/bin/env bash

set -euo pipefail

. src/homebrew.sh

# 此安裝有以下限制:
# - 沒有 `nix` 套件管理器，因為它需要 `sudo`（至少在 Mac 上）
# - 沒有 `sudo` 指令

provision_setup_minimal() {
  provision_setup_env
  provision_setup_top
  provision_setup_os
  provision_setup_homebrew
  provision_setup_zsh
  provision_setup_general
  provision_setup_nvim
  provision_setup_java
  provision_setup_js
  provision_setup_ruby
  provision_setup_rust
  provision_setup_cli_tools
  provision_setup_android
  provision_setup_vscode
  provision_setup_end
}
