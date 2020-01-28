# ts START

# Dependencies:
# - after: js.sh

install_node_modules typescript tslint

install_vim_package quramy/tsuquyomi
install_vim_package leafgarland/typescript-vim

cat >> ~/.vimrc <<"EOF"
autocmd FileType typescript :exe ConsoleMappingA
autocmd FileType typescript :exe ConsoleMappingB

" run tslint and prettier over file
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kb :!tslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "nnoremap <silent> <c-a> :update<cr>:!tslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "inoremap <silent> <c-a> <c-c>:update<cr>:!tslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kB :!./node_modules/.bin/prettier --write %<cr>:e<cr>"

" ts linters
  let g:syntastic_typescript_checkers = ['tsuquyomi', 'tslint']

augroup SyntaxSettings
  autocmd!
  autocmd BufNewFile,BufRead *.tsx set filetype=typescript
augroup END

let g:tsuquyomi_disable_default_mappings = 1
let g:tsuquyomi_disable_quickfix = 1
let g:ale_linters_ignore = {'typescript': ['eslint']}
EOF

# ts END
