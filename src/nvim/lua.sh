#!/usr/bin/env bash

set -e

provision_setup_nvim_lua() {
  mkdir -p ~/.vim/lua
  cd ~/development/environment

  mkdir -p ~/.config/nvim/ftplugin
  cp src/nvim/lua/sh.lua ~/.config/nvim/ftplugin/sh.lua

  rsync \
    -rh \
    --exclude=examples.lua \
    --exclude=sh.lua \
    --delete \
    ~/development/environment/src/nvim/lua/ \
    ~/.vim/lua/
}
