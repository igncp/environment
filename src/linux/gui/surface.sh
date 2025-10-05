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
    "$HOME/development/environment/src/scripts/misc/surface_launch_chrome.sh" 'launch_chrome_surface' 'Launch Chrome in Surface'

  add_desktop_common \
    "$HOME/development/environment/src/scripts/misc/surface_set_touchpad.sh" 'surface_disable_touchpad' 'Disable the Touchpad in Surface'

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

# 令到部相機運作:
# ## Debian (可能唔係全部都係必要嘅)
# - Linux Surface kernel: `apt install -y linux-image-surface linux-headers-surface libwacom-surface && sudo update-grub`
# - 從源頭建立咗個 libcamera: `git clone https://git.libcamera.org/libcamera/libcamera.git --depth 1 && cd libcamera && meson build && ninja -C build install`
# - `sudo apt install -y cheese`
# - `sudo apt install -y v4l-utils`
# - `cat /etc/apt/sources.list`
#     deb http://deb.debian.org/debian trixie main non-free-firmware
#     deb [arch=amd64] https://pkg.surfacelinux.com/debian release main
# - 啟用 Chrome 旗號就可以用 pulseaudio/pipewire
