#!/usr/bin/env bash

# 該腳本適用於儲存庫 debian docker 開發環境

set -euo pipefail

sudo apt update
sudo apt install -y wget gnupg

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg |
  gpg --dearmor |
  sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg >/dev/null

echo "deb https://download.sublimetext.com/ apt/stable/" |
  sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt update
sudo apt install -y sublime-text

sudo apt install -y libgl1 locales
