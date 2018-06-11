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
# to enable network
  echo "sudo dhcpcd" > /home/igncp/init.sh
# to enable ssh server
  echo "sudo systemctl start sshd.service" >> /home/igncp/init.sh
  echo "sudo systemctl status sshd.service" >> /home/igncp/init.sh
echo "sudo mount -t vboxsf project /project -o uid=1000,gid=1000" >> /home/igncp/init.sh
pacman -S --noconfirm virtualbox-guest-modules-arch virtualbox-guest-utils
mkdir -p /project
usermod -G vboxsf -a igncp
chown igncp /project
rm /root/start.sh
pacman -S --noconfirm vim

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
