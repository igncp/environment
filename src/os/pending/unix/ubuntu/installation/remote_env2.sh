# @TODO
#!/usr/bin/env bash

set -euo pipefail

if [ -z "$(whoami | grep igncp || true)" ]; then
  echo 'You should run this command as the user'
  exit 1
fi

mkdir -p ~/project/provision
mkdir -p ~/project/scripts

cp environment/src/config-files/create_vim_snippets.sh ~/project/provision

if [ -f ~/development/environment/project/.config/gui-install ]; then
  cat environment/src/provision/gui-base.sh >>~/project/provision/provision.sh
  cat environment/src/os/ubuntu/provision/ubuntu-gui.sh >>~/project/provision/provision.sh
  cat environment/src/provision/gui-common.sh >>~/project/provision/provision.sh
  cat environment/src/provision/gui-xfce.sh >>~/project/provision/provision.sh
  cp environment/src/config-files/alacritty.yml ~/project/provision/alacritty.yml
  cp environment/src/config-files/fonts.conf ~/project/provision/
  cp environment/src/config-files/rime-config.yaml ~/project/provision/
  touch ~/development/environment/project/.config/common-gui-light
  touch ~/development/environment/project/.config/headless-xorg
  touch ~/development/environment/project/.config___/x11-vnc-server
fi
