#!/usr/bin/env bash

set -euo pipefail

# This diff script displays the effect of copying the repo files in custom into
# the external locations

cd ~/development/environment

if [ -d project/scripts ] || [ -d custom/scripts ]; then
  echo '- custom/scripts:'
  delta --diff-so-fancy --pager never \
    project/scripts \
    custom/scripts || true
fi

if [ -f custom/hosts ]; then
  echo '- custom/hosts:'
  delta --diff-so-fancy --pager never \
    /etc/hosts \
    custom/hosts || true
fi

if [ -f custom/ssh_config ]; then
  echo '- custom/ssh_config:'
  delta --diff-so-fancy --pager never \
    ~/.ssh/config \
    custom/ssh_config || true
fi

echo '- custom/bootstrap:'
# This is a special case to avoid comparing the `.gitignore`
while IFS= read -r FILE_NAME; do
  delta --diff-so-fancy --pager never \
    "src/scripts/bootstrap/$FILE_NAME" \
    "custom/bootstrap/$FILE_NAME" || true
done < <(find custom/bootstrap -type f -print0 | xargs -0 -n1 basename)

echo '- custom/custom.sh:'
delta --diff-so-fancy --pager never \
  custom/custom.sh \
  src/custom.sh || true

echo '- custom/.vim-custom.lua:'
delta --diff-so-fancy --pager never \
  project/.vim-custom.lua \
  custom/.vim-custom.lua || true

echo '- custom/vim-macros-custom:'
delta --diff-so-fancy --pager never \
  project/vim-macros-custom \
  custom/vim-macros-custom || true

echo '- custom/custom_create_vim_snippets.sh:'
delta --diff-so-fancy --pager never \
  project/custom_create_vim_snippets.sh \
  custom/custom_create_vim_snippets.sh || true

if [ -d ~/development/nix-envs ]; then
  echo '- custom/nix-envs:'
  delta --diff-so-fancy --pager never \
    ~/development/nix-envs \
    custom/nix-envs/ || true
fi

echo '- custom/.config:'
delta --diff-so-fancy --pager never \
  project/.config \
  custom/.config || true
