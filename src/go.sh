#!/usr/bin/env bash

set -e

provision_setup_go() {
  cat >>~/.shell_aliases <<"EOF"
if type go >/dev/null 2>&1; then
  export GOPATH="$HOME/.go-workspace"
  export GO15VENDOREXPERIMENT=1
  export PATH=$PATH:$GOPATH/bin

  if [ -n "$(find ~/.go-workspace/pkg/mod/golang.org/x/tools/ 2>/dev/null | grep gopls || true)" ]; then
    (cd ~ && go install golang.org/x/tools/gopls@latest)
  fi
fi

if type buf >/dev/null 2>&1 && [ ! -f ~/.completions/buf.zsh ]; then
  buf completion zsh >~/.completions/buf.zsh
fi
EOF

  cat >>~/.zshrc <<"EOF"
if [ -f ~/.completions/buf.zsh ]; then
  source ~/.completions/buf.zsh
fi
EOF

  cat >>~/.shell_aliases <<"EOF"
if type go >/dev/null 2>&1; then
  alias gmt='go mod tidy'

  alias DlvAllowLinux='echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope'

  alias GoInstallGorun='go install github.com/erning/gorun@latest'
  alias GoInstallDelve='go install github.com/go-delve/delve/cmd/dlv@latest'
  alias GoInstallProtocGenGo='go install google.golang.org/protobuf/cmd/protoc-gen-go@latest'
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

  cat >>~/.vim/lua/extra_beginning.lua <<"EOF"
if vim.fn.executable('go') == 1 then
  require('dap-go').setup {
    dap_configurations = {
      {
        type = "go",
        name = "Attach remote",
        mode = "remote",
        request = "attach",
      },
    },
  }
end
EOF

}
