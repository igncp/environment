# js-extras START

cat >> ~/.vimrc <<"EOF"
function! OpenJSTestOppositeFile()
  let l:dir_name = expand('%:p:h:t')
  let l:file_basename = expand('%:t:r')
  let l:dir_path = expand('%:p:h')
  if l:dir_name == '__tests__'
    let l:new_dir_path = substitute(l:dir_path, '\/__tests__$', "", "")
    let l:new_file_name = substitute(l:file_basename, '\.test$', "", "")
    let l:full_file_path = l:new_dir_path . '/' . l:new_file_name . '.js'
  else
    call system('(mkdir -p ' . l:dir_path . "/__tests__)")
    let l:full_file_path = l:dir_path . '/__tests__/' . l:file_basename . ".test.js"
  endif
  execute ':tab drop ' . l:full_file_path
endfunction
nnoremap <leader>jsj :call OpenJSTestOppositeFile()<cr>
EOF

# reason: https://github.com/facebook/reason
  echo 'eval $(opam config env)' >> ~/.bashrc
  if ! type opam > /dev/null 2>&1; then
    wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin
    opam update
    opam switch 4.03.0
    eval $(opam config env)
    cd ~
    git clone git@github.com:facebook/reason.git
    cd reason
    opam pin add -y reason-parser reason-parser
    opam pin add -y reason .
    npm install -g git://github.com/reasonml/reason-cli.git
  fi
  install_vim_package reasonml/vim-reason-loader
  cat >> ~/.vimrc <<"EOF"
  let g:deoplete#omni_patterns = {}
  let g:deoplete#omni_patterns.reason = '[^. *\t]\.\w*\|\h\w*|#'
  let g:deoplete#sources = {}
  let g:deoplete#sources.reason = ['omni', 'buffer']
  let g:syntastic_reason_checkers=['merlin']
  autocmd FileType reason nmap <buffer> <leader>kb :ReasonPrettyPrint<Cr>
EOF

# import js
  install_node_modules import-js
  install_vim_package galooshi/vim-import-js
  add_special_vim_map 'impjswor' ':ImportJSWord<cr>' 'import js word'
  add_special_vim_map 'impjswor' ':ImportJSFix<cr>' 'import js file'

# local eslint
  cat >> ~/.vimrc <<"EOF"
    if executable('node_modules/.bin/eslint')
      let b:syntastic_javascript_eslint_exec = 'node_modules/.bin/eslint'
    endif
EOF

# js-extras END
