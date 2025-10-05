#!/usr/bin/env bash

set -euo pipefail

setup_gui_hyprland() {
  if ! type hyprctl >/dev/null 2>&1; then
    return
  fi

  mkdir -p ~/.config/hypr
  # https://github.com/hyprwm/Hyprland/tree/main/example
  cp \
    ~/development/environment/src/config-files/hyprland.conf \
    /tmp/hyprland.conf

  if [ "$IS_SURFACE" == "1" ]; then
    sed -i 's|monitor=,preferred,auto,auto|monitor=,preferred,auto,1.6|' /tmp/hyprland.conf
  fi

  mv /tmp/hyprland.conf ~/.config/hypr/hyprland.conf

  if [ ! -f ~/.config/hypr/hyprpaper.conf ]; then
    touch ~/.config/hypr/hyprpaper.conf
  fi

  cp ~/development/environment/src/config-files/hypridle.conf ~/.config/hypr/

  if type waybar >/dev/null 2>&1; then
    mkdir -p ~/.config/waybar
    cp \
      ~/development/environment/src/config-files/waybar.jsonc \
      ~/.config/waybar/config.jsonc
  fi

  if [ -f "$PROVISION_CONFIG"/gui-no-1password ]; then
    cat ~/.config/hypr/hyprland.conf | grep -v 1password | sponge ~/.config/hypr/hyprland.conf
  fi
}
