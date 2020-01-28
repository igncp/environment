#!/usr/bin/env bash

set -e

pacman -Syy
pacman -S git --noconfirm
echo "Set a new password for root:"
passwd
pacman -S grub --noconfirm
# Before it was: grub-install --target=i386-pc /dev/sda
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
useradd igncp -m
echo "Set a new password for igncp:"
passwd igncp
pacman -S sudo --noconfirm
echo "igncp ALL=(ALL) ALL" >> /etc/sudoers
pacman -S openssh --noconfirm
echo "alias ll='ls -lah'" >> /home/igncp/.bashrc
pacman -S --noconfirm virtualbox-guest-modules-arch virtualbox-guest-utils
mkdir -p /project
usermod -G vboxsf -a igncp
chown igncp /project
pacman -S --noconfirm vim dhcpcd
sed -i 's|#en_US\.UTF|en_US.UTF|' /etc/locale.gen
locale-gen
localectl set-locale LANG=en_US.UTF-8
pacman -S --noconfirm cronie
curl -o /home/igncp/init.sh \
  -L https://raw.githubusercontent.com/igncp/environment/master/arch-linux/installation/vm3.sh
chown igncp /home/igncp/init.sh

  # exit
  # reboot
# Boot existing OS
# Remove ISO from devices
  # Menu > Devices > Optical Drives > Uncheck Disc
  # Force unmount
# Login as igncp
# Run:
  # sh init.sh
# From the host
  # ssh -p 3022 igncp@127.0.0.1
