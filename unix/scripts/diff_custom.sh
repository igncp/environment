#!/usr/bin/env bash

set -e

cd ~/development/environment

if [ -d project/scripts ] || [ -d custom/scripts ]; then
  echo '- custom/scripts:'
  diff -r --color=always \
    custom/scripts \
    project/scripts || true
fi

echo '- custom/bootstrap:'
diff -r --color=always \
  custom/bootstrap/ \
  unix/scripts/bootstrap/ || true

echo '- custom/custom.sh:'
diff -r --color=always \
  custom/custom.sh \
  src/custom.sh || true

echo '- custom/.vim-custom.lua:'
diff -r --color=always \
  custom/.vim-custom.lua \
  project/.vim-custom.lua || true

echo '- custom/vim-macros-custom:'
diff -r --color=always \
  custom/vim-macros-custom \
  project/vim-macros-custom || true

echo '- custom/custom_create_vim_snippets.sh:'
diff -r --color=always \
  custom/custom_create_vim_snippets.sh \
  project/custom_create_vim_snippets.sh || true

if [ -d ~/development/nix-envs ]; then
  echo '- custom/nix-envs:'
  diff -r --color=always \
    custom/nix-envs/ \
    ~/development/nix-envs || true
fi
