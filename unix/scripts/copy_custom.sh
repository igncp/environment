#!/usr/bin/env bash

set -e

cd ~/development/environment

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

if [ "$BRANCH_NAME" != "custom" ] && [ "$(git status --porcelain | wc -l | sed 's| ||g')" != "0" ]; then
  echo "You have uncommitted changes, exiting..."
  exit 1
fi

if [ "$BRANCH_NAME" != "custom" ]; then
  git checkout custom
fi

# If updating this, remember to update ./diff_custom.sh

if [ -d project/scripts ]; then
  rsync -rhv --delete ./project/scripts/ custom/scripts/
fi
if [ -d ~/development/nix-envs ]; then
  rsync -rhv --delete ~/development/nix-envs/ custom/nix-envs/
fi

rsync -rhv --delete --exclude=.gitignore unix/scripts/bootstrap/ custom/bootstrap/
rsync -rhv --delete src/custom.sh custom/custom.sh
rsync -rhv --delete project/.vim-custom.lua custom/.vim-custom.lua
rsync -rhv --delete project/vim-macros-custom custom/vim-macros-custom
rsync -rhv --delete project/custom_create_vim_snippets.sh custom/custom_create_vim_snippets.sh

if [ -n "$JUST_COMMIT" ]; then
  exit 0
fi

git add -A .
git commit -m "Update custom branch" || true

git push origin custom

if [ "$BRANCH_NAME" != "custom" ]; then
  git checkout "$BRANCH_NAME"
fi
