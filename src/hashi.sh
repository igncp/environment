#!/usr/bin/env bash

set -euo pipefail

provision_setup_hashi() {
  if [ ! -f $PROVISION_CONFIG/hashi ]; then
    return
  fi

  install_nvim_package "hashivim/vim-terraform" # https://github.com/hashivim/vim-terraform
}
