# ts START

# Dependencies:
# - after: js.sh

install_node_modules typescript tslint

install_vim_package quramy/tsuquyomi
install_vim_package leafgarland/typescript-vim

cat >> ~/.vimrc <<"EOF"
  autocmd FileType typescript :exe ConsoleMappingA
  autocmd FileType typescript :exe ConsoleMappingB

" run tslint over file
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kb :!tslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kB :!tslint --fix %<cr>:!prettier --write %<cr>:e<cr>"

" ts linters
  let g:syntastic_typescript_checkers = ['tsuquyomi', 'tslint']
EOF

cp ~/.vim-snippets/javascript.snippets ~/.vim-snippets/typescript.snippets

cat >> ~/.vimrc <<"EOF"
let g:tsuquyomi_disable_default_mappings = 1
let g:tsuquyomi_disable_quickfix = 1
let g:ale_linters_ignore = {'typescript': ['eslint']}
EOF

# ts END
