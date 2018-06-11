# haskell START

if ! type stack > /dev/null 2>&1 ; then
  echo "installing stack"
  STACK_HOME=/usr/local/lib/stack
  mkdir -p ~/stack-tmp; cd ~/stack-tmp
  download_cached https://www.archlinux.org/packages/community/x86_64/stack/download/ stack.tar.xz ~/stack-tmp
  tar -xJf stack.tar.xz
  sudo rm -rf "$STACK_HOME"; sudo mv usr "$STACK_HOME"
  "$STACK_HOME"/bin/stack setup
  cd ~; rm -rf ~/stack-tmp
fi
cat >> ~/.bashrc <<"EOF"
export PATH=$PATH:/usr/local/lib/stack/bin
eval "$(stack --bash-completion-script stack)"
EOF

cat >> ~/.bash_aliases <<"EOF"
alias runghc="stack exec runghc --silent -- -w -ihs"
alias vim="stack exec vim"
EOF

install_vim_package eagletmt/ghcmod-vim "stack install ghc-mod"
install_vim_package neovimhaskell/haskell-vim
install_vim_package nbouscal/vim-stylish-haskell "stylish-haskell --defaults > ~/.stylish-haskell.yaml"

cat >> ~/.vimrc <<"EOF"
autocmd BufWritePost *.hs :GhcModCheckAsync
autocmd BufReadPost *.hs :GhcModCheckAsync
EOF

# haskell END
