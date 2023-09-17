#!/usr/bin/env bash

set -e

provision_setup_js_vue() {
  install_nvim_package "posva/vim-vue"
  install_nvim_package "neoclide/coc-vetur"

  cat >>~/.vimrc <<'EOF'
autocmd filetype vue :set comments=://

function! NERDCommenter_before()
  if &ft == 'vue'
    let g:ft = 'vue'
    let stack = synstack(line('.'), col('.'))
    if len(stack) > 0
      let syn = synIDattr((stack)[0], 'name')
      if len(syn) > 0
        exe 'setf ' . substitute(tolower(syn), '^vue_', '', '')
      endif
    endif
  endif
endfunction

function! NERDCommenter_after()
  if get(g:, 'ft', "default") == 'vue'
    setf vue
    let g:ft = ''
  endif
endfunction

call add(g:coc_global_extensions, 'coc-vetur')

autocmd filetype vue :exe 'nnoremap <leader>jres /<script <cr>zz'
autocmd filetype vue :exe 'nnoremap <leader>jreS /<\/script<cr>zz'
autocmd filetype vue :exe 'nnoremap <leader>jrec /^export.*class<cr>zz'
autocmd filetype vue :exe 'nnoremap <leader>jreC /^export.*class<cr>j/{<cr>_zz'

" d for design. Need to press <c-a> to type at the beginning
autocmd filetype vue :exe 'nnoremap <leader>jred :let g:ctrlp_default_input=".scss"<cr>:CtrlP<cr>:let g:ctrlp_default_input=""<cr>'
EOF
}
