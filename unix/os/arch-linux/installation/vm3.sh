#!/usr/bin/env bash

# Only run as user this with a new `project` directory

set -e

if [ -z "$(whoami | grep igncp || true)" ]; then
  echo 'You should run this command as the user'
  exit 1
fi

echo 'Remember to review the provisions in this file before running'

read -p "Do you want to continue? (yY) " -n 1 -r; echo ''; if ! [[ $REPLY =~ ^[Yy]$  ]]; then exit; fi

if [ ! -d environment ]; then
  echo 'Send the environment directory via rsync'
  # From the host:
    # rsync -r ./ igncp@192.168.1.X:/home/igncp/environment
    # ssh igncp@192.168.1.X
    # sh vm3.sh
  exit 1
fi

mkdir -p ~/project/provision
mkdir -p ~/project/scripts

if [ -f ~/project/provision/provision.sh ]; then
  cp ~/project/provision/provision.sh ~/project/provision/provision_backup.sh
fi

cp environment/unix/config-files/create_vim_snippets.sh ~/project/provision

cp environment/unix/provision/top.sh ~/project/provision/provision.sh
cat environment/unix/os/arch-linux/provision/arch-beginning.sh >> ~/project/provision/provision.sh
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

cat environment/unix/provision/gui-base.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/gui-common.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/gui-i3.sh >> ~/project/provision/provision.sh
cp environment/unix/config-files/fonts.conf ~/project/provision/
cp environment/unix/config-files/i3blocks.sh ~/project/provision/
cp environment/unix/config-files/alacritty.yml ~/project/provision/
cp environment/unix/config-files/i3-config ~/project/provision/
cp environment/unix/config-files/picom.conf ~/project/provision/
cp environment/unix/config-files/rime-config.yaml ~/project/provision/

cat environment/unix/os/arch-linux/provision/arch-gui.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/cli-tools.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/android.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/vscode.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/docker.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/rust.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/custom.sh >> ~/project/provision/provision.sh

cp environment/unix/os/arch-linux/config-files/data.updateProvision.js ~/project/provision
cp environment/unix/config-files/updateProvision.js ~/project/provision

mkdir ~/project/.config
touch ~/project/.config/inside # Some settings depend on this, like SSH password auth

if [ ! -f ~/.ssh/config ]; then
  mkdir -p ~/.ssh
  cp environment/unix/config-files/ssh-client-config ~/.ssh/config
fi

if [ ! -d ~/project/scripts/toolbox ]; then
  rsync -rhv --delete environment/unix/scripts/ ~/project/scripts/
fi

echo "** Remove ~/vm3.sh if nothing to save **"

echo "finished correctly"
