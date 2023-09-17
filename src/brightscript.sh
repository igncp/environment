#!/usr/bin/env bash

set -e

provision_setup_brightscript() {
  if [ ! -f "$PROVISION_CONFIG"/brightscript ]; then
    return
  fi

  install_nvim_package chooh/brightscript.vim

  cat >>~/.vimrc <<"EOF"
let g:NERDCustomDelimiters = { 'brs': { 'left': "'",'right': ''  }  }
au BufRead,BufNewFile *.brs set filetype=brs
au FileType brs set tabstop=4
au FileType brs set shiftwidth=4
au FileType brs set softtabstop=4
EOF
}
