#!/usr/bin/env bash

set -euo pipefail

setup_gui_dunst() {
  if ! type dunst >/dev/null 2>&1; then
    return
  fi

  mkdir -p ~/.config/dunst
  cp "$HOME/development/environment/src/config-files/dunstrc" ~/.config/dunst/dunstrc
}
