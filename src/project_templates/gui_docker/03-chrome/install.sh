#!/usr/bin/env bash

# 該腳本適用於儲存庫 debian docker 開發環境

set -euo pipefail

mkdir ~/chrome_install
cd ~/chrome_install
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || true
sudo apt -f -y install
sudo rm -rf google-chrome-stable_current_amd64.deb
cd && sudo rm -rf ~/chrome_install
