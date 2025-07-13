#!/usr/bin/env bash

set -euo pipefail

# https://wiki.archlinux.org/title/wireshark
# https://docs.mitmproxy.org/stable/overview-installation/
# - Local instance: http://mitm.it/
provision_setup_general_network() {
  if [ ! -f "$PROVISION_CONFIG"/network-analysis ]; then
    return
  fi

  if [ -f "$PROVISION_CONFIG"/gui ]; then
    install_system_package wireshark
  fi

  install_system_package mitmproxy
}
