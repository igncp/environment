#!/usr/bin/env bash

# Installation scripts for UEFI Boot as host

# Windows: Use UUI to setup a Live USB: https://www.pendrivelinux.com/universal-usb-installer-easy-as-1-2-3/
# Arch: Use dd: https://wiki.archlinux.org/index.php/USB_flash_installation_media

# Note down WIFI password

# Whole process: https://www.youtube.com/watch?v=QP68hRqQTJ4

# Encryption:
# - https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system
# - https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system

# Run these commands manually depending on your needs:

cfdisk /dev/sda # Manage partitions
  # Choose to delete all
  # Create a new one of type EFI System (500M).
  # Create a one / several of type Linux Filesystem
    # It is nice to have `/project` and `/home/igncp` in a different partitions
    # Need to format them in following steps
    # The swap is added later in efi2.sh via file
  # Write

# Basic encryption steps (will clear disk)
  # cryptsetup -y -v luksFormat /dev/sdaX
  # cryptsetup open /dev/sdaX CRYPTNAME
  # mkfs.ext4 /dev/mapper/CRYPTNAME

wifi-menu # Wait a few seconds
ping archlinux.org # to confirm that network works
mkfs.fat -F32 /dev/sda1 # Boot partition
mkfs.ext4 /dev/sda2 # Rest of the partitions
mount /dev/sda2 /mnt # Root partition
pacstrap /mnt base linux linux-firmware
genfstab -U -p /mnt >> /mnt/etc/fstab # try to move this to efi2.sh
arch-chroot /mnt

curl -L ignaciocarbajo.com/arch-efi | bash # efi2.sh
sh /tmp/efi.sh
