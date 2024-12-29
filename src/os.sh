#!/usr/bin/env bash

set -e

. src/os/arch.sh
. src/os/debian.sh
. src/os/mac.sh
. src/os/nixos/base.sh
. src/os/windows.sh

provision_setup_os() {
  if [ "$IS_MAC" = "1" ]; then
    provision_setup_os_mac
  elif [ "$IS_NIXOS" = "1" ]; then
    provision_setup_os_nixos
  elif [ "$IS_DEBIAN" = "1" ]; then
    provision_setup_os_debian
  elif [ "$IS_ARCH" = "1" ]; then
    provision_setup_os_arch
  elif [ "$IS_WINDOWS" = "1" ]; then
    provision_setup_os_windows
  fi
}
