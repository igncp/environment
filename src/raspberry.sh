#!/usr/bin/env bash

set -e

provision_setup_raspberry() {
  if [ ! -f "$PROVISION_CONFIG"/raspberry ]; then
    return
  fi

  # To setup Wifi in Ubuntu
  #   sudo apt-get install -y network-manager ; nmtui
  #   Or setup: /etc/netplan/50-cloud-init.yaml
  #   network:
  #       ethernets:
  #           eth0:
  #               dhcp4: true
  #               optional: true
  #       wifis:
  #           wlan0:
  #               dhcp4: true
  #               optional: true
  #               access-points:
  #                   WIFI_NAME:
  #                       password: WIFI_PASS
  #       version: 2

  install_system_package raspi-config

  cat >>~/.shell_aliases <<"EOF"
# From libraspberrypi-bin
alias RaspberryTemp='vcgencmd measure_temp'
EOF

  # Enable VNC: https://www.pitunnel.com/doc/access-vnc-remote-desktop-raspberry-pi-over-internet

  if [ "$IS_DEBIAN" == "1" ]; then
    if [ ! -f ~/.check-files/raspi-tools ]; then
      sudo apt install -y linux-tools-raspi
      touch ~/.check-files/raspi-tools
    fi
  fi

  # Install desktop environment:
  # `sudo apt install xserver-xorg raspberrypi-ui-mods`

  # Kodi:
  # `sudo apt install -y kodi kodi-peripheral-joystick`
  # sudo usermod -a -G audio,video,input,dialout,plugdev,netdev,users,cdrom,tty $USER
  # 可以建立一個systemd服務:
  # `ExecStart=/usr/lib/aarch64-linux-gnu/kodi/kodi.bin`

  # https://retropie.org.uk/docs/Nintendo-Switch-Controllers/

  # To over-clock: https://www.zdnet.com/article/upgrading-your-pc-this-monster-graphics-card-is-200-off/
  # In `/boot/config.txt` (only `arm_freq` is present in the config, but commented out)
  # arm_freq=2000
  # over_voltage=6
  # gpu_freq = 750

  # Web based VNC client (noVNC), can be converted to a systemd service:
  # https://github.com/novnc/noVNC

  # Enable camera:
  # `sudo modprobe bcm2835-v4l2`
}
