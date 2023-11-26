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
alias gmt='go mod tidy'
EOF

  if [ ! -d ~/.go-workspace/pkg/mod/golang.org/x/tools/gopls* ]; then
    (cd ~ && go install golang.org/x/tools/gopls@latest)
  fi

  # Issue with this plugin was fixed with: `sudo rm -rf ~/.config/coc/extensions/coc-go-data/`
  install_nvim_package "josa42/coc-go"

  if ! type gorun >/dev/null 2>&1; then
    go install github.com/erning/gorun@latest
  fi

  cat >>~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-go')

let g:go_def_mapping_enabled = 0
let g:go_doc_keywordprg_enabled = 0

autocmd filetype go vnoremap <leader>kk "iyOfmt.Println("a", a);<c-c>6hidebug: <c-r>=expand('%:t')<cr>: <c-c>lv"ipf"lllv"ip
EOF

}
