#!/usr/bin/env bash

set -e

provision_setup_top() {
  mkdir -p ~/.check-files
  mkdir -p ~/.scripts
  mkdir -p ~/development/environment/project/.config

  echo '' >~/.shellrc
  echo '' >~/.shell_aliases
  echo '' >~/.shell_sources
  echo '' >~/.vimrc
  echo '' >~/.inputrc
  echo '' >~/.bashrc
  echo '' >~/.zshrc
  echo '' >/tmp/expected-vscode-extensions
}
