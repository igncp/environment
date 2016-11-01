# js START

NODE_VERSION=6.3.0
if [ ! -f ~/.node-installation-finished ]; then
  echo "setup node with nodenv"
  cd ~
  sudo add-apt-repository -y ppa:chris-lea/node.js && \
    sudo apt-get update && \
    sudo curl -O -L https://npmjs.org/install.sh | sh && \
    if [ ! -d ~/.nodenv ]; then git clone https://github.com/nodenv/nodenv.git ~/.nodenv && cd ~/.nodenv && src/configure && make -C src; fi && \
    export PATH=$PATH:/home/$USER/.nodenv/bin && \
    eval "$(nodenv init -)" && \
    if [ ! -d ~/.nodenv/plugins/node-build ]; then git clone https://github.com/nodenv/node-build.git $(nodenv root)/plugins/node-build; fi && \
    if [ ! -d .nodenv/versions/$NODE_VERSION ]; then nodenv install $NODE_VERSION; fi && \
    nodenv global $NODE_VERSION && \
    touch ~/.node-installation-finished
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

install_node_modules http-server diff-so-fancy yarn

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

cat >> ~/.vimrc <<"EOF"

" quick console.log , once it finishes: <C-n> s
  let ConsoleMapping="nnoremap <leader>k iconsole.log('a', a);<C-c>hhhhhhh :call multiple_cursors#new('n', 0)<CR>"
  autocmd FileType javascript :exe ConsoleMapping
  autocmd FileType typescript :exe ConsoleMapping
EOF

# js END
