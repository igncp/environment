#!/usr/bin/env bash

set -e

provision_setup_gui_surface() {
  if [ "$IS_SURFACE" != "1" ]; then
    return
  fi

  if [ -f /etc/default/grub ] && [ -n "$(cat /etc/default/grub | grep '#GRUB_GFXMODE' || true)" ]; then
    # 增加 grub 字體大小
    sudo sed -i 's|.*GRUB_GFXMODE=.*|GRUB_GFXMODE=640x480|' /etc/default/grub
    sudo update-grub
  fi

  if [ ! -f "$PROVISION_CONFIG"/vpn_check ]; then
    echo yes >"$PROVISION_CONFIG"/vpn_check
  fi

  cat >>~/.shell_aliases <<'EOF'
SurfaceDecreaseBrightness() {
  sudo brightnessctl s 10%-
}
SurfaceIncreaseBrightness() {
  sudo brightnessctl s 10%+
}
Battery() {
  BATTERY_LINE="$(upower --enumerate | grep battery_BAT)"
  upower -i "$BATTERY_LINE" | less
}
EOF
}
