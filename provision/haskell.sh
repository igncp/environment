# haskell START

if ! type stack > /dev/null 2>&1 ; then
  echo "installing haskell"
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 575159689BEFB442 && \
    echo 'deb http://download.fpcomplete.com/ubuntu trusty main'|sudo tee /etc/apt/sources.list.d/fpco.list && \
    sudo apt-get update && sudo apt-get install stack -y && \
    stack setup && \
    stack upgrade --git && \
    stack install stylish-haskell
fi

cat >> ~/.bashrc <<"EOF"

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