#!/usr/bin/env bash

set -e

# Download Virtual Box
  # On Mac, currently it needs to be v5.x
  # https://www.virtualbox.org/wiki/Download_Old_Builds
# Download Arch Linux ISO image
# Create new Virtual Box image
  # VDI > Dynamically Allocated > Choose dir and Size
# Choose ISO and boot Arch Linux
# Add port forwarding:
  # Menu > Device > Network > Network Settings > Advanced > Port Forwading
  # (name) ssh (type) TCP (host) 3022 (guest) 22
# Setup bidirectional clipboard
# Remove mini-menu UI (the last of the options in the left bar)
# Add shared folder
  # Menu > Devices > Shared Folders > Settings > Add new
  # Check: Make Permanent, Auto-Mount
  # Used names (2): project and vm-shared

# Run these commands manually depending on your needs

cfdisk /dev/sda # create new partition: n p <enter> <enter> <enter> w
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt # should be the partition to contain the system
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
curl -L ignaciocarbajo.com/arch-vm | bash # vm2.sh
