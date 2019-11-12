#!/usr/bin/env bash

# Installation scripts for UEFI Boot as host

# Windows: Use UUI to setup a Live USB: https://www.pendrivelinux.com/universal-usb-installer-easy-as-1-2-3/
# Arch: Use dd: https://wiki.archlinux.org/index.php/USB_flash_installation_media

# Note down WIFI password

# Whole process: https://www.youtube.com/watch?v=QP68hRqQTJ4

# Run these commands manually depending on your needs:

cfdisk /dev/sda # Manage partitions
  # Choose to delete all
  # Create a new one of type EFI System (500M).
  # Create a new one of type Linux Filesystem: Rest of partition size
  # Write

wifi-menu # Wait a few seconds
ping archlinux.org # to confirm that network works
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
pacstrap /mnt base linux linux-firmware
genfstab -U -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt

curl -L ignaciocarbajo.com/arch-efi | bash # efi2.sh
