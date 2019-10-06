#!/usr/bin/env bash

set -e

# to enable network
  sudo dhcpcd
# to enable ssh server
  sudo systemctl start sshd.service
  sudo systemctl status sshd.service

sudo mount -t vboxsf project /project -o uid=1000,gid=1000
sudo systemctl start systemd-timesyncd.service
sudo systemctl start cronie

if [ -f /project/provision/provision.sh ]; then
  sh /project/provision/provision.sh
fi
