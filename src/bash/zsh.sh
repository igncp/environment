#!/usr/bin/env bash

set -e

provision_setup_zsh() {
  if [ ! -f ~/.bun/_bun ] && type "bun" >/dev/null 2>&1; then
    bun completions
  fi

  cat >>~/.zshrc <<"EOF"
[ -s "/home/igncp/.bun/_bun" ] && source "/home/igncp/.bun/_bun"
EOF
}
