#!/usr/bin/env bash

set -e

provision_setup_general_nushell() {
  if ! type nu >/dev/null 2>&1; then
    return
  fi

  mkdir -p $HOME/.config/nushell
  cp src/config-files/config.nu $HOME/.config/nushell/config.nu
}
