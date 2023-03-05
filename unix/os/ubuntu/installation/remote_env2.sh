#!/usr/bin/env bash

set -e

if [ -z "$(whoami | grep igncp || true)" ]; then
  echo 'You should run this command as the user'
  exit 1
fi

mkdir -p ~/project/provision
mkdir -p ~/project/scripts

cp environment/unix/config-files/create_vim_snippets.sh ~/project/provision
cp environment/unix/provision/top.sh ~/project/provision/provision.sh
cat environment/unix/os/ubuntu/provision/ubuntu-beginning.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/zsh.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/general.sh >> ~/project/provision/provision.sh
cp environment/unix/config-files/htoprc ~/project/provision/
cat environment/unix/provision/linux.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/python.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/vim-base.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/vim-extra.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/vim-root.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/js.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/ts.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/vim-coc.sh >> ~/project/provision/provision.sh

if [ -f ~/project/.config/gui-install ]; then
  cat environment/unix/provision/gui-base.sh >> ~/project/provision/provision.sh
  cat environment/unix/os/ubuntu/provision/ubuntu-gui.sh >> ~/project/provision/provision.sh
  cat environment/unix/provision/gui-common.sh >> ~/project/provision/provision.sh
  cat environment/unix/provision/gui-xfce.sh >> ~/project/provision/provision.sh
  cp environment/unix/config-files/alacritty.yml ~/project/provision/alacritty.yml
  cp environment/unix/config-files/fonts.conf ~/project/provision/
  cp environment/unix/config-files/rime-config.yaml ~/project/provision/
  touch ~/project/.config/common-gui-light
  touch ~/project/.config/headless-xorg
  touch ~/project/.config/x11-vnc-server
fi

cat environment/unix/provision/custom.sh >> ~/project/provision/provision.sh

cp environment/unix/os/ubuntu/config-files/data.updateProvision.json ~/project/provision

if [ ! -f ~/.ssh/config ]; then
  mkdir -p ~/.ssh
  cp environment/unix/config-files/ssh-client-config ~/.ssh/config
fi

if [ ! -d ~/project/scripts/toolbox ]; then
  rsync -rhv --delete environment/unix/scripts/ ~/project/scripts/
fi
