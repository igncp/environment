#!/usr/bin/env bash

# Setup USB:
  # Arch Ventoy:
    # yay -Sy ventoy-bin --noconfirm
    # sudo /opt/ventoy/Ventoy2Disk.sh -i /dev/sdb
    # sudo pacman -S ntfs-3g
    # sudo mkfs.ntfs -Q /dev/sdb1
    # sudo mount /dev/sdb1 /mnt
    # sudo rsync --progress ~/Downloads/Win11_EnglishInternational_x64v1.iso /mnt
      # Takes around 5 minutes in USB3
    # sudo umount /mnt

# IME
    # Download and install: https://rime.im/
    # Right click in bottom right, package manager > Install `rime-cantonese`
    #   - An alternative way is via Plum: Download the windows installer from:
    #       - https://github.com/rime/plum#windows
    #       - Download: https://github.com/rime/plum-windows-bootstrap/archive/master.zip
    #       - Download as zip: https://github.com/rime/rime-cantonese/archive/refs/heads/main.zip
    #       - After downloaded and installed, can go to the IME settings in the taskbar icon and choose it
    # F4 or Ctrl+` for settings

