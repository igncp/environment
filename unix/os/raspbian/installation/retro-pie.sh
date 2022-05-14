#!/bin/bash

set -e

# Download: https://retropie.org.uk/download/
# **Important**: Decompress the file: gzip -d FILE_NAME.img.gz
# sudo snap install rpi-imager
# sudo rpi-imager # Needs to use `sudo`
# Mount SD and create ssh.txt file in the root of the boot partition
# Reboot PI and SSH into the machine
    # https://retropie.org.uk/docs/SSH/

sudo apt-get update

# For xrandr
sudo apt-get install -y x11-xserver-utils

sudo apt-get install -y silversearcher-ag
