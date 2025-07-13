#!/usr/bin/env bash

set -euo pipefail

provision_setup_haskell() {
  if [ ! -f "$PROVISION_CONFIG"/haskell ]; then
    return
  fi

  install_system_package ghc
  install_system_package stack

  cat >>~/.shellrc <<"EOF"
export PATH=$PATH:/usr/local/lib/stack/bin
export PATH=$PATH:~/.cabal/bin
EOF

  cat >>~/.shellrc <<"EOF"
eval "$(stack --bash-completion-script stack)"
EOF

  cat >>~/.shell_aliases <<"EOF"
alias runghc="stack exec runghc --silent -- -w -ihs"
EOF

  install_nvim_package eagletmt/ghcmod-vim "stack install ghc-mod"
  install_nvim_package nbouscal/vim-stylish-haskell
  install_nvim_package neovimhaskell/haskell-vim "stylish-haskell --defaults > ~/.stylish-haskell.yaml"

  cat >>~/.vimrc <<"EOF"
autocmd BufWritePost *.hs :GhcModCheckAsync
autocmd BufReadPost *.hs :GhcModCheckAsync
EOF
}
