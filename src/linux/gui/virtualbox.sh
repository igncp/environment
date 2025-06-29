#!/usr/bin/env bash

set -e

provision_gui_virtualbox() {
  if [ ! -f "$PROVISION_CONFIG"/gui-virtualbox ]; then
    return
  fi

  # https://www.linuxtechi.com/how-to-install-virtualbox-on-debian/
  if [ "$IS_DEBIAN" == "1" ] && [ -n "$(grep bookworm /etc/os-release || true)" ]; then
    if type -p virtualbox &>/dev/null; then
      return
    fi

    sudo apt install gnupg2 lsb-release -y
    curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/vbox.gpg
    curl -fsSL https://www.virtualbox.org/download/oracle_vbox.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/oracle_vbox.gpg

    echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" |
      sudo tee /etc/apt/sources.list.d/virtualbox.list

    sudo apt update
    sudo apt install linux-headers-$(uname -r) dkms -y
    sudo apt install virtualbox-7.0 -y

    sudo usermod -aG vboxusers $USER
    newgrp vboxusers

    wget https://download.virtualbox.org/virtualbox/7.0.10/Oracle_VM_VirtualBox_Extension_Pack-7.0.10.vbox-extpack
    sudo vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-7.0.10.vbox-extpack

    rm -rf ./Oracle_VM_VirtualBox_Extension_Pack-7.0.10.vbox-extpack
  fi
}
