#!/usr/bin/env bash

# This file is intended to be run as root in chroot mode

set -e

pacman -S git --noconfirm
useradd igncp -m
echo "Change password on login"
echo "igncp:igncp" | chpasswd
pacman -S sudo --noconfirm
echo "# igncp ALL=(ALL) ALL" >> /etc/sudoers
echo "igncp ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers # For the initial installation
echo "alias ll='ls -lah'" >> /home/igncp/.bashrc
pacman -S --noconfirm dhcpcd
pacman -S --noconfirm openssh rsync

ssh-keygen -A

# comment if not installing a vbox VM
pacman -S --noconfirm virtualbox-guest-utils
usermod -G vboxsf -a igncp
systemctl enable vboxservice.service

systemctl enable dhcpcd.service
systemctl enable sshd.service

pacman -S --noconfirm ufw

systemctl enable systemd-timesyncd.service

sed -i 's|#en_US\.UTF|en_US.UTF|' /etc/locale.gen
locale-gen
localectl set-locale LANG=en_US.UTF-8

# Change the default `umask` to be more restrictive
sed -i 's|^umask.*|umask 0077|' /etc/profile

pacman -S --noconfirm apparmor

# alternative: sudo journalctl --vacuum-size=500M
journalctl --vacuum-time=10d

cp /root/.vimrc /home/igncp/.vimrc || true
chown -R igncp:igncp /home/igncp/.vimrc || true

cp /root/vm3.sh /home/igncp/
chown -R igncp:igncp /home/igncp/
rm -f ~/vm2.sh
