#!/usr/bin/env bash

set -e

mkdir -p /home/igncp/misc
git clone git://github.com/igncp/environment.git /home/igncp/misc/environment

sudo mkdir -p /project
sudo chown igncp /project

mkdir -p /project/provision
cp /home/igncp/misc/environment/arch-linux/provision/general.sh /project/provision/provision.sh

{
  echo ""
  cat /home/igncp/misc/environment/arch-linux/provision/vim-base.sh
  echo ""
  cat /home/igncp/misc/environment/arch-linux/provision/vim-extra.sh
} >> /project/provision/provision.sh

mkdir -p /project/scripts
cp /home/igncp/misc/environment/arch-linux/scripts/create_vim_snippets.sh /project/scripts

sudo systemctl enable systemd-timesyncd.service
sudo systemctl enable sshd.service
# sudo systemctl enable dhcpcd.service # This has problems in latest installations after second reboot

echo "## Last steps:"
echo "# Enable network with netctl"
echo "# Update locale"
echo "sudo vim /etc/locale.gen # uncomment one"
echo "sudo locale-gen"
echo "sudo vim /etc/systemd/logind.conf # for power management actions"
echo "rm /home/igncp/first_after_install.sh"
