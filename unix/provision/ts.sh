# ts START

# Dependencies:
# - after: js.sh

install_vim_package neoclide/coc-tsserver

cat >> ~/.vimrc <<"EOF"
autocmd FileType typescript :exe ConsoleMappingA
autocmd FileType typescript :exe ConsoleMappingB

" run eslint and prettier over file
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kb :!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "nnoremap <silent> <c-a> :update<cr>:!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "inoremap <silent> <c-a> <c-c>:update<cr>:!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"
  autocmd filetype typescript :exe "vnoremap <silent> <leader>kB :'<,'>PrettierFragment<cr>"

call add(g:coc_global_extensions, 'coc-tsserver')

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
EOF

sed -i '$ d' ~/.vim/coc-settings.json
cat >> ~/.vim/coc-settings.json <<"EOF"
  ,
  "typescript.suggestionActions.enabled": false
}
EOF

cat > /tmp/colors.vim <<"EOF"
hi tsxTagName ctermfg=91 cterm=bold
hi tsxIntrinsicTagName ctermfg=91 cterm=bold
hi tsxAttrib cterm=bold
EOF
if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|=91|=153|' /tmp/colors.vim
fi
cat /tmp/colors.vim >> ~/.vim/colors.vim ; rm /tmp/colors.vim

# ts END
