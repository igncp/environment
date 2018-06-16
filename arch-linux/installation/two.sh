#!/usr/bin/env bash

pacman -Syy
pacman -S git --noconfirm
echo "Set a new password for root:"
passwd
pacman -S grub --noconfirm
grub-install --target=i386-pc /dev/sda
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
rm /root/start.sh
pacman -S --noconfirm vim
sed -i 's|#en_US\.UTF|en_US.UTF|' /etc/locale.gen
locale-gen
curl -o /home/igncp/init.sh \
  -L https://raw.githubusercontent.com/igncp/environment/master/arch-linux/installation/three.sh

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
