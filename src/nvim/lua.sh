#!/usr/bin/env bash

set -e

provision_setup_nvim_lua() {
  mkdir -p ~/.vim/lua
  cd ~/development/environment

  rsync \
    -rh \
    --exclude=examples.lua \
    --delete \
    ~/development/environment/src/nvim/lua/ \
    ~/.vim/lua/
}
