#!/usr/bin/env bash

# Download Arch Linux ISO image
# Create new Virtual Box image
  # VDI > Dynamically Allocated > Choose dir and Size
# Choose ISO and boot Arch Linux
# Add port forwarding:
  # Menu > Device > Network > Network Settings > Advanced > Port Forwading
  # (name) ssh (type) TCP (host) 3022 (guest) 22
# @TODO: Improve partitions for performance
# @TODO: Find a way to automate these too using curl
  # fdisk /dev/sda # create new partition: n p <enter> <enter> <enter> w
  # mkfs.ext4 /dev/sda1
  # mount /dev/sda1 /mnt
  # pacstrap /mnt base
  # genfstab -U /mnt >> /mnt/etc/fstab
  # arch-chroot /mnt
# @TODO: Automate these using curl
# Run:
  # pacman -Syy
  # pacman -S git
  # git clone https://github.com/igncp/vagrant-personal-cookbook.git /root/p
  # sh /root/p/arch-linux/installation/one.sh

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
echo "sudo dhcpcd" > /home/igncp/.init.sh
echo "sudo systemctl start sshd.service" >> /home/igncp/.init.sh
echo "sudo systemctl status sshd.service" >> /home/igncp/.init.sh

  # exit
  # reboot
# Boot existing OS
# Remove ISO from devices
# Run:
  # sh .init.sh
# From the host
  # ssh -p 3022 igncp@127.0.0.1
