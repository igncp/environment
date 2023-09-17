#!/usr/bin/env bash

set -e

install_nvim_package() {
  REPONAME=$1
  CMD=$2

  EXTRA_CMD=""
  if [ -n "$CMD" ]; then
    EXTRA_CMD=', build = "'"$CMD"'"'
  fi

  sed -i "/local nvim_plugins = {/a { '$REPONAME'$EXTRA_CMD }," \
    ~/.vim/lua/extra_beginning.lua
}

. src/nvim/vim.sh
. src/nvim/root.sh
. src/nvim/lua.sh
. src/nvim/base.sh
. src/nvim/coc.sh
. src/nvim/special_mappings.sh
. src/nvim/textobj.sh

provision_setup_nvim() {
  provision_setup_nvim_vim
  provision_setup_nvim_root
  provision_setup_nvim_lua
  provision_setup_nvim_base
  provision_setup_nvim_coc
  provision_setup_nvim_special_mappings
  provision_setup_nvim_textobj
}
