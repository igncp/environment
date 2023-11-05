#!/usr/bin/env bash

set -e

provision_setup_go() {
  if [ ! -f "$PROVISION_CONFIG"/go ]; then
    return
  fi

  cat >>~/.shellrc <<"EOF"
export GOPATH="$HOME/.go-workspace"
export GO15VENDOREXPERIMENT=1
export PATH=$PATH:$GOPATH/bin
EOF

  cat >>~/.shell_aliases <<"EOF"
# This is for vim-go
GoInitEditor() {
  (cd ~ && go install golang.org/x/tools/gopls@latest)
  echo "You have to run :GoInstallBinaries inside nvim"
}
alias gmt='go mod tidy'
EOF

  install_nvim_package "josa42/coc-go"
  install_nvim_package "fatih/vim-go"

  cat >>~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-go')

let g:go_def_mapping_enabled = 0
let g:go_doc_keywordprg_enabled = 0

autocmd filetype go vnoremap <leader>kk "iyOfmt.Println("a", a);<c-c>6hidebug: <c-r>=expand('%:t')<cr>: <c-c>lv"ipf"lllv"ip
EOF

  if [ -f "$PROVISION_CONFIG"/go-cosmos ]; then
    if ! type "ignite" >/dev/null 2>&1; then
      echo "Installing ignite"
      curl https://get.ignite.com/cli@! | bash
    fi
  fi
}
