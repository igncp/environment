#!/usr/bin/env bash

# This file is intended to be run as root in chroot mode

set -e

# installing again in case encryption was not necessary
  pacman -Syy
  pacman -S --noconfirm grub vim

# Before it was: grub-install --target=i386-pc /dev/sda
  grub-install /dev/sda
  grub-mkconfig -o /boot/grub/grub.cfg

pacman -S git --noconfirm
useradd igncp -m
echo "Set a new password for root:"
passwd
echo "Set a new password for igncp:"
passwd igncp
pacman -S sudo --noconfirm
echo "igncp ALL=(ALL) ALL" >> /etc/sudoers
echo "alias ll='ls -lah'" >> /home/igncp/.bashrc
pacman -S --noconfirm dhcpcd cronie
pacman -S --noconfirm openssh rsync

ssh-keygen -A

# comment if not using vbox
pacman -S --noconfirm virtualbox-guest-utils
usermod -G vboxsf -a igncp
systemctl enable vboxservice.service

systemctl enable dhcpcd.service
systemctl enable sshd.service

pacman -S --noconfirm ufw

systemctl enable systemd-timesyncd.service
systemctl enable ufw

sed -i 's|#en_US\.UTF|en_US.UTF|' /etc/locale.gen
locale-gen
localectl set-locale LANG=en_US.UTF-8

# alternative: sudo journalctl --vacuum-size=500M
journalctl --vacuum-time=10d

cp /root/.vimrc /home/igncp/.vimrc || true
chown -R igncp:igncp /home/igncp/.vimrc || true

echo 'exit'
echo 'umount -a'
echo 'shutdown now'
echo 'sh host/eject_dvd.sh'
echo 'Remove entry from hosts ~/.ssh/known_hosts'
echo 'SSH as igncp'

cp /root/vm3.sh /home/igncp/
chown -R igncp:igncp /home/igncp/
rm -f ~/vm2.sh
