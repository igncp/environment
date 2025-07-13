#!/usr/bin/env bash

set -euo pipefail

# 常見嘅設定:
# - 加入 chromium 擴充程式，但係唔好以使用者身分登入
# - 設定藍牙同信任喇叭
# https://retropie.org.uk/docs/Nintendo-Switch-Controllers/

provision_setup_gaming() {
  if [ ! -f "$PROVISION_CONFIG"/gaming ]; then
    return
  fi

  if [ "$IS_DEBIAN" != "1" ]; then
    echo "Gaming provision expects a Debian system"
    return
  fi

  install_system_package_os terminator

  if [ -n "$(cat /etc/default/keyboard | grep '"gb"')" ]; then
    sudo sed -i 's|"gb"|"us"|' /etc/default/keyboard
    echo "Changed keyboard layout to US"
  fi

  # # Favor having a dual-boot over a VM
  # #
  # # In raspbian, after installing, use `raspi-config` to login into console,
  # # and start it manually
  # if [ ! -d ~/RetroPie-Setup ]; then
  #   sudo apt update && sudo apt upgrade
  #   sudo apt install -y git dialog unzip xmlstarlet
  #   cd ~

  #   # Necessary for some cases
  #   sudo apt-get install software-properties-common
  #   sudo apt update

  #   git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
  #   cd RetroPie-Setup
  #   sudo ./retropie_setup.sh

  #   # Extra emulator docs
  #   # - DOSBox: https://retropie.org.uk/docs/PC/

  #   sudo apt install -y flatpak
  #   sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  #   sudo flatpak install -y flathub net.pcsx2.PCSX2
  #   # Press F9 to use software renderer
  #   # Press F6 to change the aspect ratio

  #   echo "Early return in provision after RetroPie setup, run $(Provision) again"
  #   exit 0
  # fi

  if [ -f "$PROVISION_CONFIG"/gaming-ps2 ]; then
    if [ ! -f ~/.check-files/gaming-ps2 ]; then
      # Press F9 to use software renderer
      # Press F6 to change the aspect ratio
      sudo apt install -y flatpak
      sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      sudo flatpak install -y flathub net.pcsx2.PCSX2
      touch ~/.check-files/gaming-ps2
    fi
  fi

  cat >>~/development/environment/project/backup.sh <<"EOF"
if [ -d ~/RetroPie/roms ]; then
  rsync -rh --delete --exclude='ps2' ~/RetroPie/roms/ "$BACKUP_PATH/retropie_roms/"
fi
if [ -d ~/RetroPie/BIOS ]; then
  rsync -rh --delete ~/RetroPie/BIOS "$BACKUP_PATH/retropie_bios/"
fi
if [ -d ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates ]; then
  rsync -rh --delete ~/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates/ \
    "$BACKUP_PATH/retropie_ps2_states/"
fi
EOF
}
