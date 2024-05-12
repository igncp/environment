#!/usr/bin/env bash

set -e

provision_setup_gaming() {
  if [ ! -f "$PROVISION_CONFIG"/gaming ]; then
    return
  fi

  if [ "$IS_DEBIAN" != "1" ]; then
    echo "Gaming provision expects a Debian system"
    return
  fi

  # https://retropie.org.uk/docs/Nintendo-Switch-Controllers/

  # Favor having a dual-boot over a VM
  if [ ! -d ~/RetroPie-Setup ]; then
    sudo apt update && sudo apt upgrade
    sudo apt install -y git dialog unzip xmlstarlet
    cd ~

    # Necessary for some cases
    sudo apt-get install software-properties-common
    sudo apt update

    git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
    cd RetroPie-Setup
    sudo ./retropie_setup.sh

    # Extra emulator docs
    # - DOSBox: https://retropie.org.uk/docs/PC/

    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y flathub net.pcsx2.PCSX2
    # Press F9 to use software renderer
    # Press F6 to change the aspect ratio

    echo "Early return in provision after RetroPie setup, run $(Provision) again"
    exit 0
  fi

  cat >>~/.shell_aliases <<"EOF"
MinecraftServer() {
  mkdir -p ~/misc/minecraft
  (cd ~/misc && \
    docker run \
      -it \
      --restart always \
      --name minecraft-server \
      -d \
      -p 25565:25565 \
      -e EULA=TRUE \
      -v "$(pwd)/minecraft":/data \
      itzg/minecraft-server)
}
EOF

  cat >>~/development/environment/project/backup.sh <<"EOF"
if [ -d ~/misc/minecraft/world ]; then
  rsync -rh --delete ~/misc/minecraft/world/ "$BACKUP_PATH/minecraft_world/"
fi
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
