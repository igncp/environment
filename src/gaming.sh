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

  if [ ! -d ~/RetroPie-Setup ]; then
    sudo apt update && sudo apt upgrade
    sudo apt install -y git dialog unzip xmlstarlet
    cd ~
    git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
    cd RetroPie-Setup
    sudo ./retropie_setup.sh

    # Necessary for some cases
    sudo apt-get install software-properties-common
    sudo apt update

    cd ~/development/environment
  fi

  cat >> ~/.shell_aliases <<"EOF"
MinecraftServer() {
  mkdir -p ~/misc/minecraft
  (cd ~/misc && \
    docker run --rm -it \
      -p 25565:25565 \
      -e EULA=TRUE \
      -v "$(pwd)/minecraft":/data \
      itzg/minecraft-server)
}
EOF
}
