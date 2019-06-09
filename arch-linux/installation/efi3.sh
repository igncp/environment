#!/usr/bin/env bash

mkdir /home/igncp/misc
git clone git://github.com/igncp/environment.git /home/igncp/misc/environment

sudo mkdir -p /project
sudo chown igncp /project

mkdir /project/provision
cp /home/igncp/misc/environment/arch-linux/provision/general.sh /project/provision/provision.sh

{
  echo ""
  cat /home/igncp/misc/environment/arch-linux/provision/vim-base.sh
  echo ""
  cat /home/igncp/misc/environment/arch-linux/provision/vim-extra.sh
} >> /project/provision/provision.sh

sudo systemctl enable systemd-timesyncd.service
sudo systemctl enable sshd.service
sudo systemctl enable dhcpcd.service

echo "last steps:"
echo "# Enable network with netctl"
echo "rm /home/igncp/first_after_install.sh"
