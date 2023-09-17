#!/usr/bin/env bash

set -e

cd ~/development/environment

diff -r --color=always \
  custom/scripts \
  project/scripts

diff -r --color=always \
  custom/bootstrap/ \
  unix/scripts/bootstrap/

diff -r --color=always \
  custom/custom.sh \
  src/custom.sh

diff -r --color=always \
  custom/.vim-custom.lua \
  project/.vim-custom.lua

diff -r --color=always \
  custom/vim-macros-custom \
  project/vim-macros-custom

diff -r --color=always \
  custom/custom_create_vim_snippets.sh \
  project/custom_create_vim_snippets.sh
