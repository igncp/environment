# vim-coc START

## ctrl-w,ctrl-p: move to floating window
# - To remove an extension after installed, comment lines and then: :CocUninstall coc-name
# - To open multiple references at once: enter in visual mode inside the quickfix window and select multiple
#   - Press `t` to open each case in new tab, press `enter` to open each file (unless already opened) in new tab

install_vim_package neoclide/coc.nvim
install_vim_package josa42/coc-sh
install_vim_package neoclide/coc-snippets
install_vim_package neoclide/coc-git
install_vim_package neoclide/coc-lists

cat >> ~/.vimrc <<"EOF"
function! GetColorInCursor()
  echo synIDattr(synID(line("."), col("."), 1), "name")
endfunction

let g:coc_global_extensions = []
nnoremap <silent> K :call CocAction('doHover')<CR>

inoremap <expr> <c-j> pumvisible() ? "<C-n>" :"j"
inoremap <expr> <c-k> pumvisible() ? "<C-p>" : "k"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> g[ <Plug>(coc-diagnostic-prev)
nmap <silent> g] <Plug>(coc-diagnostic-next)

nnoremap <silent> <leader>dd :<C-u>CocList diagnostics<cr>
nnoremap <leader>dc :CocList commands<cr>
nnoremap <leader>de :CocEnable<cr>
nnoremap <leader>dE :CocDisable<cr>
nnoremap <leader>ds :CocCommand<cr>
nnoremap <leader>da :CocAction<cr>
vnoremap <leader>da :CocAction<cr>
nnoremap <leader>df <Plug>(coc-fix-current)
vnoremap <leader>df <Plug>(coc-fix-current)
nnoremap <leader>dl <Plug>(coc-codelens-action)
nnoremap <leader>do <Plug>(coc-codeaction)
nnoremap <leader>dr <Plug>(coc-rename)
command! -nargs=? Fold :call CocAction('fold', <f-args>)

call add(g:coc_global_extensions, 'coc-snippets')
call add(g:coc_global_extensions, 'coc-sh')
call add(g:coc_global_extensions, 'coc-git')
call add(g:coc_global_extensions, 'coc-lists')

imap <C-l> <Plug>(coc-snippets-expand-jump)
smap <C-l> <Plug>(coc-snippets-expand-jump)
let g:coc_snippet_next = '<c-d>'

nnoremap <nowait><expr> <C-g> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-g> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
EOF

cat >> ~/.vim/colors.vim <<"EOF"
highlight CocErrorFloat ctermfg=black
highlight CocFloating ctermbg=lightcyan
highlight CocInfoFloat ctermfg=black
highlight CocWarningFloat ctermfg=black
highlight CocHighlightRead ctermfg=black ctermbg=none
highlight CocHighlightWrite ctermfg=black ctermbg=none
highlight CocErrorLine ctermfg=black ctermbg=none
highlight CocWarningLine ctermfg=black ctermbg=none
highlight CocInfoLine ctermfg=black ctermbg=none
highlight CocErrorSign ctermfg=white ctermbg=darkred
highlight CocWarningSign ctermfg=white ctermbg=darkred
EOF

cat > "$HOME"/.vim/coc-settings.json <<"EOF"
{
  "diagnostic.enableHighlightLineNumber": false,
  "coc.preferences.jumpCommand": "tab drop",
  "coc.preferences.enableFloatHighlight": false,
  "coc.preferences.colorSupport": false,
  "snippets.userSnippetsDirectory": "$HOME/.vim-snippets",
  "diagnostic.errorSign": "E",
  "diagnostic.warningSign": "W",
  "diagnostic.infoSign": "I",
  "list.normalMappings": {
    "<C-j>": "command:CocNext",
    "<C-k>": "command:CocPrev"
  }
}
EOF

install_vim_package neoclide/coc-json

cat >> ~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-json')
EOF

if [ ! -d ~/.vim/bundle/coc.nvim/node_modules ]; then
  (cd ~/.vim/bundle/coc.nvim && yarn)
fi

install_vim_package neoclide/coc-html
install_vim_package neoclide/coc-css

# coc-eslint can be disabled due performance
# To remove: `CocUninstall coc-eslint`
# Confirm with: `CocList`
if [ ! -f ~/project/.config/without-coc-eslint ]; then
  install_vim_package neoclide/coc-eslint
  cat >> ~/.vimrc <<"EOF"
  call add(g:coc_global_extensions, 'coc-eslint')
EOF
fi

cat >> ~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-html')
call add(g:coc_global_extensions, 'coc-css')

" https://github.com/neoclide/coc-css#install
autocmd FileType scss setl iskeyword+=@-@
EOF

# The filetypes and probe is to disable on Markdown
sed -i '$ d' ~/.vim/coc-settings.json
cat >> ~/.vim/coc-settings.json <<"EOF"
  ,
  "eslint.autoFixOnSave": true,
  "eslint.filetypes": ["javascript", "javascriptreact", "typescript", "typescriptreact", "vue"],
  "eslint.probe": ["javascript", "javascriptreact", "typescript", "typescriptreact", "vue"],
  "javascript.suggestionActions.enabled": false,
  "prettier.disableSuccessMessage": true
}
EOF
if [ -f ~/project/.config/coc-eslint-no-fix-on-save ]; then
  sed -i 's|"eslint.autoFixOnSave": true,$|"eslint.autoFixOnSave": false,|' ~/.vim/coc-settings.json
fi

install_vim_package neoclide/coc-tsserver

cat >> ~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-tsserver')

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
EOF

sed -i '$ d' ~/.vim/coc-settings.json
cat >> ~/.vim/coc-settings.json <<"EOF"
  ,
  "typescript.suggestionActions.enabled": false
}
EOF

if type rustc > /dev/null 2>&1 ; then
  install_vim_package neoclide/coc-rls
  cat >> ~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-rls')
EOF
  sed -i '$ d' ~/.vim/coc-settings.json
  cat >> ~/.vim/coc-settings.json <<"EOF"
  ,
  "rust.clippy_preference": "on"
}
EOF
fi

# To try:
# - https://github.com/tjdevries/coc-zsh
# - https://github.com/iamcco/coc-diagnostic
# - https://github.com/neoclide/coc-jest

# vim-coc END
