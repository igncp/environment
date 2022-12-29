#!/usr/bin/env bash

# Check notes/vms.md
# Download Ubuntu Server: https://ubuntu.com/download/server

# Follow wizard of Ubuntu Server
  # Choose encryption with LVM and Luks for main system
  # Choose to install SSH Server
  # Takes several minutes to install

set -e

sudo apt-get update
sudo apt-get install -y virtualbox-guest-dkms virtualbox-guest-utils
sudo usermod -a -G vboxsf igncp
sudo ufw limit ssh
sudo reboot

# next: ./vm2.sh
