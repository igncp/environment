#!/usr/bin/env bash

set -euo pipefail

provision_setup_js_ts() {
  cat >>~/.vimrc <<'EOF'
autocmd FileType typescript,typescriptreact :exe ConsoleMappingA
autocmd FileType typescript,typescriptreact :exe ConsoleMappingB

" run eslint and prettier over file
  autocmd filetype typescript,typescriptreact :exe "nnoremap <silent> <leader>kb :!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript,typescriptreact :exe "nnoremap <silent> <c-a> :update<cr>:!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript,typescriptreact :exe "inoremap <silent> <c-a> <c-c>:update<cr>:!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript,typescriptreact :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"
  autocmd filetype typescript,typescriptreact :exe "vnoremap <silent> <leader>kB :'<,'>PrettierFragment<cr>"
EOF

  if type npm >/dev/null 2>&1; then
    if ! type typescript-language-server &>/dev/null; then
      npm install -g typescript-language-server
    fi

    if ! type vscode-eslint-language-server &>/dev/null; then
      npm install -g vscode-langservers-extracted
    fi

    if ! type bash-language-server &>/dev/null; then
      npm install -g bash-language-server
    fi
  fi
}
