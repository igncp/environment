#!/usr/bin/env bash

set -e

provision_setup_env() {
  IS_NIXOS=$(uname -a | grep -c NixOS || true)
  IS_MAC=""
  if [[ $OSTYPE == 'darwin'* ]]; then
    IS_MAC="1"
  fi

  PROVISION_CONFIG=~/development/environment/project/.config

  install_nvim_package() {
    REPONAME=$1

    sed -i "/local nvim_plugins = {/a { '$REPONAME' }," \
      ~/.vim/lua/extra_beginning.lua
  }
}
