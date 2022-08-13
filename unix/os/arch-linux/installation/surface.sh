#!/usr/bin/env bash

# First install the firmware updates via Windows
# Settings > System > Recovery > Advanced Startup
# Troubleshoot > UEFI system settings
  # Disable secureboot
  # Change the boot order

setfont /usr/share/kbd/consolefonts/ter-132n.psf.gz

# Increase the grub font size
sed -i 's|.*GRUB_GFXMODE=.*|GRUB_GFXMODE=640x480|' /etc/default/grub

# https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup#arch
  curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | sudo pacman-key --add -
  sudo pacman-key --finger 56C464BAAC421453
  sudo pacman-key --lsign-key 56C464BAAC421453
  cat >> /etc/pacman.conf <<"EOF"
[linux-surface]
Server = https://pkg.surfacelinux.com/arch/
EOF
  sudo pacman -Syu
  sudo pacman -S linux-surface linux-surface-headers
  # Update grub to save and start the last selected item

# `arandr`
# 1280x800

# Add `video` group to the `igncp` user
# yay -Sy libcamera-git

# Follow instructions from './host-efi1.sh'
