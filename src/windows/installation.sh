#!/usr/bin/env bash

# 設定安裝 USB
#   Arch:
#     yay -Sy ventoy-bin --noconfirm
#     sudo /opt/ventoy/Ventoy2Disk.sh -i /dev/sdb
#     sudo pacman -S ntfs-3g
#     sudo mkfs.ntfs -Q /dev/sdb1
#     sudo mount /dev/sdb1 /mnt
#     sudo rsync --progress ~/Downloads/Win11_EnglishInternational_x64v1.iso /mnt
#     喺 USB3入面大約需要5分鐘
#     sudo umount /mnt
#   NixOS:
#     # SudoNix woeusb --device ~/Downloads/Win11_24H2_English_x64.iso /dev/sda
#     # 應該要好耐
#     ....

# IME
#   下載同安裝: https://rime.im/download/
#   喺右下角任務列嘅「中」符號入面右擊
#   揀第一個選單選項 ("S")
#   喺對話框入面，撳一下右下角嘅掣: 獲取更多轉入方案
#   開咗個終端視窗，入面有啲指示，安裝: `rime/rime-cantonese`
#   退出終端機，喺清單入面揀選框: 粵語拼音
#   F4 或者 Ctrl+` 用嚟設定
