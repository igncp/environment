#!/usr/bin/env bash

set -e

provision_setup_nix() {
  mkdir -p ~/.config/nix
  mkdir -p ~/.pip

  cat >~/.config/nix/nix.conf <<"EOF"
experimental-features = nix-command flakes
EOF

  cat >>~/.shellrc <<"EOF"
if [ -d $HOME/.pip/lib ]; then
  export PIP_PREFIX=$HOME/.pip
  export PYTHONPATH=$(echo $HOME/.pip/lib/*/site-packages | tr " " ":")
  export PATH="$HOME/.pip/bin:$PATH"
fi
EOF

  cat >>~/.shell_aliases <<"EOF"
alias NixClearSpace='nix-collect-garbage'
alias NixInstallPackage='nix-env -iA'
alias NixListChannels='nix-channel —-list'
alias NixListGenerations="nix-env --list-generations"
alias NixListPackages='nix-env --query "*"'
alias NixListReferrers='nix-store --query --referrers' # Add the full path of the store item
alias NixRemovePackage='nix-env -e'
alias NixUpdate='nix-env -u && nix-channel --update && nix-env -u'
alias NixEvalFile='nix-instantiate --eval'

alias NixDevelop='NIX_SHELL_LEVEL=1 nix develop -c zsh'
alias NixDevelopPath='NIX_SHELL_LEVEL=1 nix develop path:$(pwd) -c zsh'
alias NixDevelopBase='NIX_SHELL_LEVEL=1 nix develop'
alias NixDevelopBasePath='NIX_SHELL_LEVEL=1 nix develop path:$(pwd)'

alias HomeManagerInitFlake='nix run home-manager/release-23.05 -- init'
alias HomeManagerDeleteGenerations='home-manager expire-generations "-1 second"'

alias SudoNix='sudo --preserve-env=PATH env'

SwitchHomeManager() {
    # Impure is needed for now to read the config
    home-manager switch --impure --flake ~/development/environment/nixos/home-manager
}

# # To patch a binary interpreter path, for example for 'foo:
# patchelf --set-interpreter /usr/lib64/ld-linux-aarch64.so.1 ./foo
# # To read the current interpreter:
# readelf -a ./foo | ag interpreter
# # To print the dynamic libraries:
# ldd -v ./foo
# # To find libraries that need patching
# ldd ./foo | grep 'not found'
# # To find the interpreter in NixOS
# cat $NIX_CC/nix-support/dynamic-linker
# # To list the required dynamic libraries
# patchelf --print-needed ./foo

NixFormat() {
  if [ -n "$1" ]; then
    alejandra $@
    return
  fi
  alejandra ./**/*.nix
}
EOF

  cat >>~/.zshrc <<"EOF"
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""
EOF

  if [ "$IS_NIXOS" != "1" ]; then
    cat >>~/.shellrc <<"EOF"
if [ -f "~/.nix-profile/etc/profile.d/nix.sh" ]; then
  . ~/.nix-profile/etc/profile.d/nix.sh
fi

if [ -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
  . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
fi
EOF
  fi
}
