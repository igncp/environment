#!/usr/bin/env bash

set -e

# 腳步：
# - 使用 dd 設定即時 USB
#   - `lsblk`
#   - `sudo dd bs=4M if=/home/igncp/Downloads/nixos-gnome-23.11.5648.44733514b72e-x86_64-linux.iso of=/dev/sdb status=progress oflag=sync`
# - 安裝正常安裝（例如使用 Calamares）
# - 克隆環境儲存庫

sudo bash -c "printf $USER > /etc/nixos/user"
mkdir -p ~/.ssh && curl https://github.com/igncp.keys >~/.ssh/authorized_keys
mkdir -p ~/development/environment/project/.config
touch ~/development/environment/project/.config/gui
echo no >~/development/environment/project/.config/nvidia
sudo cp ~/development/environment/nix/nixos/templates/configuration-gui.nix /etc/nixos/configuration.nix
cd ~/development/environment
sudo nixos-rebuild switch --show-trace --flake path:"$PWD" --impure # 在環境倉庫中
# Check nmcli notes in [notes/linux.md](notes/linux.md)
