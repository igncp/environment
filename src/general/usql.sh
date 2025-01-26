#!/usr/bin/env bash

set -e

provision_setup_general_usql() {
  if [ -f ~/.local/bin/usql ] && [ "$IS_PROVISION_UPDATE" != "1" ]; then
    return
  elif [ "$IS_PROVISION_UPDATE" = "1" ]; then
    sudo rm -rf ~/.local/bin/usql
  fi

  cd ~ && sudo rm -rf .provision_install
  mkdir -p .provision_install && cd .provision_install
  local INSTALL_OS="static.*linux"
  if [ "$IS_MAC" = "1" ]; then
    local INSTALL_OS="darwin"
  fi
  local INSTALL_ARCH="$(uname -m)"
  if [ "$INSTALL_ARCH" = "x86_64" ]; then
    local INSTALL_ARCH="amd64"
  elif [ "$INSTALL_ARCH" = "aarch64" ]; then
    local INSTALL_ARCH="arm64"
  fi
  local FILE_TYPE="$INSTALL_OS-$INSTALL_ARCH"
  local DOWNLOAD_URL="$(
    curl -s https://api.github.com/repos/xo/usql/releases/latest |
      grep "browser_download_url.*$FILE_TYPE" |
      cut -d : -f 2,3 |
      tr -d '\"'
  )"
  echo "Downloading: $DOWNLOAD_URL"
  wget $DOWNLOAD_URL -O usql.tar.bz2 -q
  tar -xvjf usql.tar.bz2
  if [ -f usql_static ]; then
    mv usql_static usql
  fi
  mv usql ~/.local/bin/usql
  cd ~ && sudo rm -rf .provision_install
}
