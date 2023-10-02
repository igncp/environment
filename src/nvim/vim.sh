#!/usr/bin/env bash

set -e

provision_setup_nvim_vim() {
  cp ~/development/environment/unix/config-files/.vimrc ~/.vimrc

  if [ "$THEME" == "dark" ]; then
    sed -i 's/set background=light/set background=dark/g' ~/.vimrc
  fi

  cp ~/.vimrc ~/.base-vimrc

  cat ~/development/environment/unix/config-files/multi-os.vim >>~/.vimrc
}
