#!/usr/bin/env bash

set -euo pipefail

provision_setup_os_nixos() {
  cat >>~/.shell_aliases <<"EOF"
alias NixOsProfileHistory='nix profile history --profile /nix/var/nix/profiles/system'
alias NixOsClearSpace='sudo nix-collect-garbage'
alias NixOsListSystemGenerations='sudo nix-env --list-generations --profile /nix/var/nix/profiles/system'
EOF

  cat >>~/.zshrc <<"EOF"
SHELL=/run/current-system/sw/bin/zsh

# Uncomment this to hide direnv logs when entering a dir
# export DIRENV_LOG_FORMAT=""
EOF

  echo 'umask 0077' >/tmp/profile.local

  sudo mv /tmp/profile.local /etc/profile.local
}
