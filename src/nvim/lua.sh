#!/usr/bin/env bash

set -euo pipefail

provision_setup_nvim_lua() {
  mkdir -p ~/.vim/lua
  cd ~/development/environment

  mkdir -p ~/.config/nvim/ftplugin

  cp src/nvim/lua/sh.lua ~/.config/nvim/ftplugin/sh.lua

  cat >>~/.vimrc <<"EOF"
let PrintMappingLua="vnoremap <leader>kk \"iyOprint('a', a);<C-c>6hidebug: <c-r>=expand('%:t')<cr>: <c-c>lv\"ipf'lllv\"ip"
autocmd filetype lua :exe PrintMappingLua
EOF

  cat >>~/.shellrc <<"EOF"
if type luarocks &>/dev/null; then
  eval "$(luarocks path)"
fi
EOF

  rsync \
    -rh \
    --exclude=examples.lua \
    --exclude=sh.lua \
    --delete \
    ~/development/environment/src/nvim/lua/ \
    ~/.vim/lua/
}
