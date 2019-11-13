#!/usr/bin/env bash

# https://www.youtube.com/watch?v=QP68hRqQTJ4

pacman -Syy
pacman -S --noconfirm git vim
pacman -S --noconfirm openssh ufw
pacman -S --noconfirm netctl dialog wpa_supplicant # for wifi-menu

pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
mkdir /boot/EFI
mount /dev/sda1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo "Set a new password for root:"
passwd

useradd igncp -m
echo "Set a new password for igncp:"
passwd igncp

pacman -S sudo --noconfirm
echo "igncp ALL=(ALL) ALL" >> /etc/sudoers

curl -o /home/igncp/first_after_install.sh \
  -L https://raw.githubusercontent.com/igncp/environment/master/arch-linux/installation/efi3.sh
chown igncp /home/igncp/first_after_install.sh

echo "Next steps:"
echo "fallocate -l 8G /swapfile # use 2 times the RAM size"
echo "chmod 600 /swapfile ; mkswap /swapfile ; echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab"
echo "# or do this after reboot"
echo "exit"
echo "reboot now"
echo "wifi-menu"
echo "sh first_after_install.sh"
