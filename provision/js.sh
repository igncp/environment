# js START

NODE_VERSION=6.3.0
if [ ! -f ~/.check-files/node ]; then
  echo "setup node with nodenv"
  cd ~
  if [ ! -d ~/.nodenv ]; then git clone https://github.com/nodenv/nodenv.git ~/.nodenv && cd ~/.nodenv && src/configure && make -C src; fi && \
    export PATH=$PATH:/home/$USER/.nodenv/bin && \
    eval "$(nodenv init -)" && \
    if [ ! -d ~/.nodenv/plugins/node-build ]; then git clone https://github.com/nodenv/node-build.git $(nodenv root)/plugins/node-build; fi && \
    if [ ! -d .nodenv/versions/$NODE_VERSION ]; then nodenv install $NODE_VERSION; fi && \
    nodenv global $NODE_VERSION && \
    mkdir -p ~/.check-files && touch ~/.check-files/node
  rm -f ~/install.sh
fi

install_node_modules() {
  for MODULE_NAME in "$@"; do
    if [ ! -d ~/.nodenv/versions/$NODE_VERSION/lib/node_modules/$MODULE_NAME ]; then
      echo "doing: npm i -g $MODULE_NAME"
      npm i -g $MODULE_NAME
    fi
  done
}

install_node_modules http-server diff-so-fancy yarn eslint babel-eslint

cat >> ~/.bashrc <<"EOF"
export PATH=$PATH:/home/$USER/.nodenv/bin
export PATH=$PATH:/home/$USER/.nodenv/versions/6.3.0/bin/
eval "$(nodenv init -)"
source <(npm completion)
EOF

cat >> ~/.bash_aliases <<"EOF"
alias Serve="http-server -c-1 -p 9000"
GitDiff() { git diff --color $@ | diff-so-fancy | less -R; }
EOF

# not installing vim-javascript as it doesn't work with rainbow
install_vim_package kchmck/vim-coffee-script
install_vim_package leafgarland/typescript-vim
install_vim_package quramy/tsuquyomi
install_vim_package ternjs/tern_for_vim "cd ~/.vim/bundle/tern_for_vim; npm i"

cat >> ~/.vimrc <<"EOF"
" quick console.log
  let ConsoleMappingA="nnoremap <leader>kk iconsole.log('a', a);<C-c>6hvs"
  let ConsoleMappingB="vnoremap <leader>kk yOconsole.log('a', a);<C-c>6hvpvi'yf'lllvp"
  let ConsoleMappingC='nnoremap <leader>kj iconsole.log("LOG POINT - <C-r>=fake#gen("nonsense")<CR>");<cr><c-c>'
  let ConsoleMappingD='nnoremap <leader>kg iif () {<cr>debugger;<cr>}<cr><esc>kkkwli'
  autocmd FileType javascript :exe ConsoleMappingA
  autocmd filetype javascript :exe ConsoleMappingB
  autocmd filetype javascript :exe ConsoleMappingC
  autocmd filetype javascript :exe ConsoleMappingD
  autocmd FileType typescript :exe ConsoleMappingA
  autocmd FileType typescript :exe ConsoleMappingB
  autocmd FileType typescript :exe ConsoleMappingC
  autocmd FileType typescript :exe ConsoleMappingD

" grep same indent props
  execute 'nnoremap <leader>ki ^hv0y' . g:GrepCF_fn . ' -o "^<c-r>"\w*:"<left>'

" term
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 1
  autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR><Paste>

" run eslint over file
  nnoremap <silent> <leader>kb :!eslint --fix %<cr>:e<cr>
EOF

# js END
