# @TODO
#!/usr/bin/env bash

set -e

if [ -z "$(whoami | grep igncp || true)" ]; then
  echo 'You should run this command as the user'
  exit 1
fi

mkdir -p ~/project/provision
mkdir -p ~/project/scripts

cp environment/unix/config-files/create_vim_snippets.sh ~/project/provision

if [ -f ~/development/environment/project/.config/gui-install ]; then
  cat environment/unix/provision/gui-base.sh >>~/project/provision/provision.sh
  cat environment/unix/os/ubuntu/provision/ubuntu-gui.sh >>~/project/provision/provision.sh
  cat environment/unix/provision/gui-common.sh >>~/project/provision/provision.sh
  cat environment/unix/provision/gui-xfce.sh >>~/project/provision/provision.sh
  cp environment/unix/config-files/alacritty.yml ~/project/provision/alacritty.yml
  cp environment/unix/config-files/fonts.conf ~/project/provision/
  cp environment/unix/config-files/rime-config.yaml ~/project/provision/
  touch ~/development/environment/project/.config/common-gui-light
  touch ~/development/environment/project/.config/headless-xorg
  touch ~/development/environment/project/.config/x11-vnc-server
fi
