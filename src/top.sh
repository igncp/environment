#!/usr/bin/env bash

set -euo pipefail

provision_setup_top() {
  mkdir -p ~/.check-files
  mkdir -p ~/.scripts
  mkdir -p ~/.local/bin
  mkdir -p ~/development/environment/project/.config

  echo '' >~/.shellrc
  echo '' >~/.shell_aliases
  echo '' >~/.shell_sources
  echo '' >~/.vimrc
  echo '' >~/.inputrc
  echo '' >~/.bashrc
  echo '' >~/.zshrc
}
