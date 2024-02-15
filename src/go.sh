#!/usr/bin/env bash

set -e

provision_setup_go() {
  cat >>~/.shellrc <<"EOF"
if type go >/dev/null 2>&1; then
  export GOPATH="$HOME/.go-workspace"
  export GO15VENDOREXPERIMENT=1
  export PATH=$PATH:$GOPATH/bin

  if [ ! -d ~/.go-workspace/pkg/mod/golang.org/x/tools/gopls* ]; then
    (cd ~ && go install golang.org/x/tools/gopls@latest)
  fi

  if ! type gorun >/dev/null 2>&1; then
    go install github.com/erning/gorun@latest
  fi
fi
EOF

  cat >>~/.shell_aliases <<"EOF"
if type go >/dev/null 2>&1; then
  alias gmt='go mod tidy'
fi
EOF

  cat >>~/.vimrc <<"EOF"
if executable('go')
  call add(g:coc_global_extensions, 'coc-go')

  let g:go_def_mapping_enabled = 0
  let g:go_doc_keywordprg_enabled = 0

  autocmd filetype go vnoremap <leader>kk "iyOfmt.Println("a", a);<c-c>6hidebug: <c-r>=expand('%:t')<cr>: <c-c>lv"ipf"lllv"ip
endif
EOF

}
