#!/usr/bin/env bash

set -e

if [ -z $1 ]; then
  if [ ! -f /root/.check_files/init_docker ]; then
    apt-get update &&
      apt-get install -y \
        sudo curl xz-utils procps less openssh-server alacritty gcc

    rm /etc/localtime &&
      ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime

    useradd -l -u $HOST_UID -ms /bin/bash igncp &&
      echo "igncp ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

    mkdir -p /home/igncp
    chown igncp:igncp /home/igncp

    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen &&
      locale-gen || true

    mkdir -p /root/.check_files &&
      touch /root/.check_files/init_docker
  fi

  echo "以 igncp 使用者身分執行入口點。"
  sudo -E -u igncp HOME=/home/igncp bash /home/igncp/development/environment/src/docker_environment/entrypoint.sh igncp

  exit 0
fi

cd /home/igncp/development/environment

if [ ! -f ~/.check_files/init_docker ]; then
  sudo rm -rf /etc/bashrc.* /etc/zshrc.*
  sudo rm -rf /etc/bash.* /etc/zsh.*
  sudo rm -rf /etc/profile.d/nix.sh*

  sudo chown -R igncp ~/development/environment/project
  sudo chown igncp ~/development/environment

  mkdir -p project/.config &&
    echo 'iceberg' >project/.config/vim-theme &&
    bash src/main.sh

  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh &&
    nvim --headless "+Lazy! sync" +qa &&
    export PATH="$PATH:$HOME/.npm-packages/bin" &&
    bash src/main.sh

  mkdir -p ~/.check_files &&
    touch ~/.check_files/init_docker

  sudo groupadd -g $HOST_DOCKER_GID docker &&
    sudo usermod -a -G docker igncp

  mkdir -p ~/.fonts
  (cd ~/.fonts && wget https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Monofur/Regular/MonofurNerdFontMono-Regular.ttf)
  fc-cache -f -v || true
  # UI 應用程式的漢字
  sudo apt install -y fonts-noto
else
  sudo /nix/var/nix/profiles/default/bin/nix-daemon 2>&1 >/dev/null &
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

cd -

echo "entrypoint.sh START_SCRIPT: $START_SCRIPT"

if [ -n "$START_SCRIPT" ]; then
  eval "$START_SCRIPT"
else
  echo "啟動 zsh"
  zsh
fi
