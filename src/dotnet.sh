#!/usr/bin/env bash

set -e

provision_setup_dotnet() {
  if [ ! -f "$PROVISION_CONFIG"/dotnet ]; then
    return
  fi

  if ! type dotnet >/dev/null 2>&1; then
    cd ~
    rm -rf dotnet-installer
    mkdir dotnet-installer
    cd dotnet-installer

    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    sudo chmod +x ./dotnet-install.sh
    ./dotnet-install.sh --version latest

    cd ~
    rm -rf dotnet-installer
  fi

  cat >>~/.shellrc <<"EOF"
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools
export DOTNET_CLI_TELEMETRY_OPTOUT=1
EOF

  cat >>~/.shell_aliases <<"EOF"
alias DotnetRun='dotnet run'
EOF

  install_nvim_package OmniSharp/omnisharp-vim
}
