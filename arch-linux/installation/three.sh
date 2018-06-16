#!/usr/bin/env bash

# to enable network
  sudo dhcpcd
# to enable ssh server
  sudo systemctl start sshd.service
  sudo systemctl status sshd.service

sudo mount -t vboxsf project /project -o uid=1000,gid=1000
sudo systemctl start systemd-timesyncd.service

if [ -f /project/provision.sh ]; then
  sh /project/provision/provision.sh
fi
