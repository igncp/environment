#!/usr/bin/env bash

set -euo pipefail

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

  add_desktop_common \
    "$HOME/development/environment/src/scripts/misc/launch_chrome_surface.sh" 'launch_chrome_surface' 'Launch Chrome in Surface'

  cat >>~/.shell_aliases <<'EOF'
SurfaceDecreaseBrightness() {
  sudo brightnessctl s 10%-
}
SurfaceIncreaseBrightness() {
  sudo brightnessctl s 10%+
}
SurfaceBrightnessLowest() {
  sudo brightnessctl s 1
}
alias Battery='echo "$(cat /sys/class/power_supply/BAT1/capacity)% $(cat /sys/class/power_supply/BAT1/status)"'
EOF
}
