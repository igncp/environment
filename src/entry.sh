#!/usr/bin/env bash

set -e

. src/env.sh
. src/top.sh
. src/os.sh

. src/cli_tools.sh
. src/general.sh
. src/js.sh
. src/linux.sh
. src/nix.sh
. src/nvim.sh
. src/python.sh
. src/ruby.sh
. src/rust.sh
. src/zsh.sh
. src/homebrew.sh

. src/android.sh
. src/brightscript.sh
. src/c.sh
. src/dart.sh
. src/containers.sh
. src/dotnet.sh
. src/go.sh
. src/hashi.sh
. src/haskell.sh
. src/kotlin.sh
. src/java.sh
. src/php.sh
. src/raspberry.sh
. src/gaming.sh
. src/crypto.sh
. src/qemu.sh
. src/vscode.sh

. src/end.sh

provision_setup_with_bash() {
  provision_setup_env
  provision_setup_top

  provision_setup_python
  provision_setup_nix

  provision_setup_os

  if [ "$IS_WINDOWS" = "1" ]; then
    return
  fi

  provision_setup_homebrew
  provision_setup_zsh
  provision_setup_general
  provision_setup_nvim
  provision_setup_js
  provision_setup_rust
  provision_setup_cli_tools
  provision_setup_linux
  provision_setup_ruby

  provision_setup_android
  provision_setup_brightscript
  provision_setup_c
  provision_setup_containers
  provision_setup_crypto
  provision_setup_dart
  provision_setup_dotnet
  provision_setup_gaming
  provision_setup_go
  provision_setup_hashi
  provision_setup_haskell
  provision_setup_kotlin
  provision_setup_java
  provision_setup_php
  provision_setup_qemu
  provision_setup_raspberry
  provision_setup_vscode

  provision_setup_end
}
