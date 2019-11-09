#!/usr/bin/env bash

# Installation scripts for UEFI Boot as host

# Windows: Use UUI to setup a Live USB: https://www.pendrivelinux.com/universal-usb-installer-easy-as-1-2-3/
# Arch: Use dd: https://wiki.archlinux.org/index.php/USB_flash_installation_media

# First: Note down WIFI password

# Whole process: https://www.youtube.com/watch?v=QP68hRqQTJ4
# 1. `cfdisk /dev/sda`
#   1. Choose to delete all
#   1. Create a new one of type EFI System (500M).
#   1. Create a new one of type Linux Filesystem: Rest of partition size
#   1. Write
# 1. `reboot now`
# 1. `wifi-menu`
# 1. Wait a few seconds
# 1. `ping archlinux.org`
# @TODO: Move this script to personal website
# 1. `curl -L https://raw.githubusercontent.com/igncp/environment/master/arch-linux/installation/efi1.sh | bash`

mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
pacstrap /mnt base
genfstab -U -p /mnt >> /mnt/etc/fstab
curl -o /mnt/root/start.sh \
  -L https://raw.githubusercontent.com/igncp/environment/master/arch-linux/installation/efi2.sh

echo "Next steps:"
echo "arch-chroot /mnt"
echo "sh root/start.sh"
