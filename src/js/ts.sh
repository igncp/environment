#!/usr/bin/env bash

set -e

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
}
