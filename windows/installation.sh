#!/usr/bin/env bash

# Setup USB:
#   Arch Ventoy:
#     yay -Sy ventoy-bin --noconfirm
#     sudo /opt/ventoy/Ventoy2Disk.sh -i /dev/sdb
#     sudo pacman -S ntfs-3g
#     sudo mkfs.ntfs -Q /dev/sdb1
#     sudo mount /dev/sdb1 /mnt
#     sudo rsync --progress ~/Downloads/Win11_EnglishInternational_x64v1.iso /mnt
#     Takes around 5 minutes in USB3
#     sudo umount /mnt

# IME
#   Download and install: https://rime.im/download/
#   Right click in the 中 symbol in the taskbar in the bottom right
#   Choose the first menu option ("S")
#   In the dialog, click the bottom right button with: 獲取更多轉入方案
#   A terminal window is opened with some instructions, install: `rime/rime-cantonese`
#   Exit the terminal, select the checkbox in the list for: 粵語拼音
#   F4 or Ctrl+` for settings
