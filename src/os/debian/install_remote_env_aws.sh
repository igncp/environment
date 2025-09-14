#!/usr/bin/env bash

set -euo pipefail

# set -x

# 支援 Linux 發行版: Debian 13

# 第一次建立卷:

# Podman
#   $HOME/.config/containers/storage.conf
#   volumes_path = "/home/igncp/podman-volumes"
# sudo cp ~/development/environment/src/os/debian/remote_env_terminate.sh ~/ && sudo chown root ~/remote_env_terminate.sh && sudo chmod go-rwx ~/remote_env_terminate.sh

# 正常情況:

if [ "$(whoami)" == "admin" ]; then
  sudo bash -c 'apt update && apt upgrade -y && apt install -y git cryptsetup git uidmap cron zsh' # `uidmap` is for `podman`
  sudo bash -c "/usr/sbin/useradd -m igncp && echo 'igncp 嘅密碼' && passwd igncp && chsh -s /bin/zsh igncp"
  sudo bash -c "echo 'igncp ALL=(ALL) ALL' >>/etc/sudoers"
  sudo bash -c '/usr/sbin/cryptsetup open /dev/nvme1n1 cryptmain && mount /dev/mapper/cryptmain /home/igncp'
  sudo bash -c "echo '*/5 * * * * /bin/bash /home/igncp/remote_env_terminate.sh' | crontab -"
  echo "成功設定"
  exit
fi

if [ "$(whoami)" == "igncp" ]; then
  mkdir -p ~/nix-store && sudo mkdir -p /nix && sudo mount --bind /home/igncp/nix-store /nix
  sh <(curl -L https://nixos.org/nix/install) --daemon --yes
  HongKongTimezone
  echo "成功設定"
fi
