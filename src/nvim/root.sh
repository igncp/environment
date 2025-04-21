#!/usr/bin/env bash

set -e

provision_setup_nvim_root() {
  if [ -f "$PROVISION_CONFIG"/minimal ]; then
    return
  fi
  cat >/tmp/.root_vimrc <<"EOF"
" This file was generated from ~/development/environment
syntax off
set number
filetype plugin indent on
let mapleader = "\<Space>"
set mouse-=a
vnoremap <Del> "_d
nnoremap <Del> "_d
nnoremap Q @q
nnoremap r gt
nnoremap R gT
EOF

  ROOT_HOME=$(eval echo "~root")
  sudo mv /tmp/.root_vimrc "$ROOT_HOME"/.vimrc
}
