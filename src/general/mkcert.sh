#!/usr/bin/env bash

set -euo pipefail

provision_setup_general_mkcert() {
  # Used to run a local server with https
  # install_system_package mkcert
  # To install the root CA under NixOS:
  # - `mkcert localhost 127.0.0.1 ::1`
  # - Open in Chrome: `chrome://settings/certificates` under the "Authorities tab
  # - Import the root CA in ~/.local/share/mkcert
  # - Restart Chrome
  # - Uninstall when done as it can be used to intercept secure traffic
  # (if the root CA shared)
  # - It has the name `org-mkcert development CA`
  return
}
