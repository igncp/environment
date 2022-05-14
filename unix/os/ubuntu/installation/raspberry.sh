#!/bin/bash

set -e

# v4: https://ubuntu.com/download/raspberry-pi
# Tutorial: https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview
    # Choose the server, can install the Desktop via SSH and setup VNC easier
    # **Important**: Decompress the file: xz -d -v FILE_NAME.img.xz
    # sudo snap install rpi-imager
    # sudo rpi-imager # Needs to use `sudo`

# Once the Ubuntu server is installed
    # - Connect it to LAN
    # - Discover it with nmap and SSH into it
