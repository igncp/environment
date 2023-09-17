#!/usr/bin/env bash

set -e

. src/os/debian.sh
. src/os/mac.sh
. src/os/nixos.sh

provision_setup_os() {
  if [ "$IS_MAC" == "1" ]; then
    provision_setup_os_mac
  elif [ "$IS_NIXOS" == "1" ]; then
    provision_setup_os_nixos
  elif [ "$IS_DEBIAN" == "1" ]; then
    provision_setup_os_debian
  fi
}
