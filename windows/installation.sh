#!/usr/bin/env bash

# Setup USB:
  # Arch Ventoy:
    # yay -Sy ventoy-bin --noconfirm
    # sudo /opt/ventoy/Ventoy2Disk.sh -i /dev/sdb
    # sudo mkfs.ntfs -Q /dev/sdb1
    # sudo mount /dev/sdb1 /mnt
    # sudo umount /dev/sdb1
    # sudo rsync --progress ~/Downloads/Win11_EnglishInternational_x64v1.iso /mnt
      # Takes around 5 minutes in USB3
    # sudo umount /mnt
