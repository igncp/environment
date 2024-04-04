#!/usr/bin/env bash

set -e

# 腳步：
# - 使用 dd 設定即時 USB
#   - `lsblk`
#   - `sudo dd bs=4M if=/home/igncp/Downloads/nixos-gnome-23.11.5648.44733514b72e-x86_64-linux.iso of=/dev/sdb status=progress oflag=sync`
# - 安裝正常安裝（例如使用 Calamares）
# - 克隆環境儲存庫
# - 將基本 `configuration.nix` 檔案複製到 `/etc/nixos/configuration.nix`
#   - 例如 `~/development/environment/nix/nixos/templates/sample-base-config.nix`
# - 運行：`sudo nixos-rebuild switch --flake . --impure` 在環境倉庫中
