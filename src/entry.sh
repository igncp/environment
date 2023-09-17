#!/usr/bin/env bash

set -e

. src/env.sh
. src/top.sh
. src/os.sh

. src/nix.sh
. src/zsh.sh
. src/general.sh
. src/nvim.sh
. src/js.sh
. src/rust.sh
. src/cli_tools.sh
. src/linux.sh

. src/android.sh
. src/brightscript.sh
. src/c.sh
. src/dart.sh
. src/docker.sh
. src/dotnet.sh
. src/go.sh
. src/hashi.sh
. src/haskell.sh
. src/kotlin.sh
. src/php.sh
. src/raspberry.sh
. src/gaming.sh
. src/ruby.sh

. src/custom.sh

provision_setup_with_bash() {
  provision_setup_env
  provision_setup_top

  provision_setup_nix

  provision_setup_os

  provision_setup_zsh
  provision_setup_general
  provision_setup_nvim
  provision_setup_js
  provision_setup_rust
  provision_setup_cli_tools
  provision_setup_linux

  provision_setup_android
  provision_setup_brightscript
  provision_setup_c
  provision_setup_dart
  provision_setup_docker
  provision_setup_dotnet
  provision_setup_go
  provision_setup_hashi
  provision_setup_haskell
  provision_setup_kotlin
  provision_setup_php
  provision_setup_raspberry
  provision_setup_gaming
  provision_setup_ruby

  provision_setup_custom
}
