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

  # # 如果要睇4K電影，喺/boot/firmware/config.txt 入面，（如果係 dtoverlay ，請取代現有嘅）
  # # https://www.raspberrypi.com/documentation/computers/config_txt.html
  # dtoverlay=vc4-kms-v3d,cma-512
  # hdmi_enable_4kp60=1

  # Enable VNC: https://www.pitunnel.com/doc/access-vnc-remote-desktop-raspberry-pi-over-internet

  # Retropie: Check in the `gaming.sh`

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
