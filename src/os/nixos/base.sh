#!/usr/bin/env bash

set -e

provision_setup_os_nixos() {
  cat >>~/.shell_aliases <<"EOF"
alias NixOsProfileHistory='nix profile history --profile /nix/var/nix/profiles/system'

ConfigNixOsProvisionList() {
    if [ -n "$1" ]; then
        ~/.scripts/cargo_target/release/provision_choose_config "$1"
        return
    fi
    ~/.scripts/cargo_target/release/provision_choose_config && RebuildNixOs && Provision
}

alias NixDevelopPath='nix develop path:$(pwd)' # Also possible to just run a command: `NixDevelopPath -c cargo build`
alias NixOsClearSpace='sudo nix-collect-garbage'
alias NixOsListSystemGenerations='sudo nix-env --list-generations --profile /nix/var/nix/profiles/system'
alias ProvisionNixOs="(RebuildNixOs && Provision)"

# 由於是通用命令而有不同的前綴
RebuildNixOs() {
  # 它需要 --impure 標誌，因為它導入/etc/nixos/configuration.nix配置
  (cd ~/development/environment && \
    sudo nixos-rebuild switch --show-trace --flake path:$PWD --impure)
}
EOF

  cat >>~/.zshrc <<"EOF"
SHELL=/run/current-system/sw/bin/zsh

# Uncomment this to hide direnv logs when entering a dir
# export DIRENV_LOG_FORMAT=""
EOF

  echo 'umask 0077' >/tmp/profile.local

  sudo mv /tmp/profile.local /etc/profile.local
}
