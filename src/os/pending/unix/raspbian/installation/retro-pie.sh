# @TODO
#!/bin/bash

set -euo pipefail

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

# For starting over SSH
sudo apt-get install -y xinit

sudo apt-get install -y silversearcher-ag

# Add this to: /etc/network/interfaces for automatic lan and
# auto eth0
# iface eth0 inet dhcp

# For wifi, needs to setup the configuration file
# auto wlan0
# iface wlan0 inet dhcp
# wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

# Disable default VNC in raspi-config

# Disable emulationstation autologin in retropie-config
