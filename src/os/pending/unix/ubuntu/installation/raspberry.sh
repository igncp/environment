# @TODO
#!/bin/bash

set -euo pipefail

# v4: https://ubuntu.com/download/raspberry-pi
# Tutorial: https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview
#     Choose the server, can install the Desktop via SSH and setup VNC easier
#     **Important**: Decompress the file: xz -d -v FILE_NAME.img.xz
#     sudo snap install rpi-imager
#     sudo rpi-imager # Needs to use `sudo`

# Once the Ubuntu server is installed
#     - Connect it to LAN
#     - Discover it with nmap and SSH into it
#     - Update resolv.conf with `nameserver 8.8.8.8`

# If there is no audio, set the default sink with `pacmd set-default-sink SINK_NAME`
#     - Run `pacmd list-sinks` to get the name

# For TV
#     - Add this in `/boot/firmware/config.txt`
#         hdmi_mode=64
#         hdmi_group=1
#         # At the end:
#         dtoverlay=vc4-fkms-v3d
#         gpu_mem=128
#         hdmi_drive=2
#     sudo apt-get install libgles2-mesa libgles2-mesa-dev xorg-dev
