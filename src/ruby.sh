#!/usr/bin/env bash

set -e

INSTALLED_GEMS=""

install_ruby_gems() {
  if [ -z "$INSTALLED_GEMS" ]; then
    INSTALLED_GEMS="$(gem list)"
  fi

  if [ -z "$(echo "$INSTALLED_GEMS" | grep "$1" || true)" ]; then
    echo "Installing gem: $1"
    gem install --user-install "$1"
  fi
}

provision_setup_ruby() {
  if [ ! -f "$PROVISION_CONFIG"/ruby ]; then
    return
  fi

  if [ -d ~/.gem/ruby ]; then
    GEM_PATHS="$(find ~/.gem/ruby -maxdepth 1 -mindepth 1)"
    for GEM_PATH in $GEM_PATHS; do
      echo 'export PATH="$PATH:'"$GEM_PATH/bin"'"' >>~/.shellrc
    done
  fi

  mkdir -p ~/.gem

  install_ruby_gems bundler
  install_ruby_gems lolcat
  install_ruby_gems fit-commit

  install_nvim_package vim-ruby/vim-ruby # https://github.com/vim-ruby/vim-ruby
}
