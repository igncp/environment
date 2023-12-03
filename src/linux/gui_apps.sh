#!/usr/bin/env bash

set -e

provision_setup_linux_gui_apps() {
  if [ ! -f "$PROVISION_CONFIG"/gui_apps ]; then
    return
  fi

  install_system_package_os terminator
  TERMINATOR_CONFIG_PATH="$HOME/.config/terminator/config"
  if [ -f "$TERMINATOR_CONFIG_PATH" ]; then
    cp ~/development/environment/src/config-files/terminator-config "$TERMINATOR_CONFIG_PATH"
  fi
}
