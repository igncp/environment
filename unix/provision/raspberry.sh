# raspberry START

# To setup Wifi in Ubuntu
  # sudo apt-get install -y network-manager ; nmtui
  # Or setup: /etc/netplan/50-cloud-init.yaml
  # network:
  #     ethernets:
  #         eth0:
  #             dhcp4: true
  #             optional: true
  #     wifis:
  #         wlan0:
  #             dhcp4: true
  #             optional: true
  #             access-points:
  #                 WIFI_NAME:
  #                     password: WIFI_PASS
  #     version: 2

install_system_package raspi-config

cat >> ~/.shell_aliases <<"EOF"
# From libraspberrypi-bin
alias RaspberryTemp='vcgencmd measure_temp'
EOF

# raspberry END
