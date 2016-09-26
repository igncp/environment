#!/usr/bin/env bash

install_vim_package() {
  REPO=$1
  DIR=$(echo $REPO | sed -r "s|.+/(.+)|\1|") # foo/bar => bar
  EXTRA_CMD=$2
  if [ ! -d ~/.vim/bundle/"$DIR" ]; then
    git clone https://github.com/$REPO.git ~/.vim/bundle/"$DIR"
    if [[ ! -z $EXTRA_CMD ]]; then eval $EXTRA_CMD; fi
  fi
}

mkdir -p ~/.vim/autoload/ ~/.vim/bundle
if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
  curl https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim \
    > ~/.vim/autoload/pathogen.vim
fi

install_vim_package airblade/vim-gitgutter
install_vim_package ctrlpvim/ctrlp.vim
install_vim_package elzr/vim-json
install_vim_package jiangmiao/auto-pairs
install_vim_package milkypostman/vim-togglelist
install_vim_package nathanaelkane/vim-indent-guides
install_vim_package ntpeters/vim-better-whitespace
install_vim_package plasticboy/vim-markdown
install_vim_package scrooloose/nerdcommenter
install_vim_package scrooloose/syntastic
install_vim_package shougo/neocomplete.vim "sudo apt-get install -y vim-nox"
install_vim_package shougo/vimproc.vim "cd ~/.vim/bundle/vimproc.vim && make; cd -"
install_vim_package vim-airline/vim-airline
install_vim_package vim-airline/vim-airline-themes
install_vim_package vim-scripts/cream-showinvisibles
install_vim_package evidens/vim-twig
# haskell
  install_vim_package eagletmt/ghcmod-vim "stack install ghc-mod"
  install_vim_package €neovimhaskell/haskell-vim
# python
  install_vim_package nvie/vim-flake8
# coffescript
  install_vim_package kchmck/vim-coffee-script
# java
  install_vim_package tfnico/vim-gradle
