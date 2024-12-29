#!/usr/bin/env bash

# 睇下 src/os/debian/surface.sh 有更多提示

# https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup#arch
curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc |
  sudo pacman-key --add -
sudo pacman-key --finger 56C464BAAC421453
sudo pacman-key --lsign-key 56C464BAAC421453
cat >>/etc/pacman.conf <<"EOF"
[linux-surface]
Server = https://pkg.surfacelinux.com/arch/
EOF
sudo pacman -Syu
sudo pacman -S linux-surface linux-surface-headers
