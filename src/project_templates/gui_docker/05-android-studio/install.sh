#!/usr/bin/env bash

# 該腳本適用於儲存庫 debian docker 開發環境

set -e

sudo dpkg --add-architecture i386

sudo apt update

sudo apt install -y \
  build-essential git neovim wget unzip sudo \
  libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 \
  libxrender1 libxtst6 libxi6 libfreetype6 libxft2 xz-utils vim \
  bridge-utils libnotify4 libglu1 libvirt-daemon-system \
  libqt5widgets5 openjdk-17-jdk xvfb rsync tmux
# qemu qemu-kvm

sudo adduser igncp libvirt
sudo adduser igncp kvm

sudo usermod -aG plugdev igncp
sudo usermod -aG render igncp

ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.3.1.20/android-studio-2022.3.1.20-linux.tar.gz
ANDROID_STUDIO_VERSION=2022.3.1.20

cd

wget "$ANDROID_STUDIO_URL" -O android-studio.tar.gz
tar xzvf android-studio.tar.gz
rm android-studio.tar.gz

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || true
sudo apt -f -y install
