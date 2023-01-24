#!/usr/bin/env bash

set -e

if [ ! -d environment ]; then
  echo 'Send via rsync the environment directory'
  # From the host:
    # rsync -rhv ./ 192.168.1.X:/home/igncp/environment
    # ssh 192.168.1.X
  exit 1
fi

mkdir -p ~/project/provision
mkdir -p ~/project/scripts

if [ -f ~/project/provision/provision.sh ]; then
  cp ~/project/provision/provision.sh ~/project/provision/provision_backup.sh
fi

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
cat environment/unix/provision/cli-tools.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/rust.sh >> ~/project/provision/provision.sh
cat environment/unix/provision/custom.sh >> ~/project/provision/provision.sh

cp environment/unix/os/ubuntu/config-files/data.updateProvision.js ~/project/provision
cp environment/unix/config-files/updateProvision.js ~/project/provision

if [ ! -f ~/.ssh/config ]; then
  mkdir -p ~/.ssh
  cp environment/unix/config-files/ssh-client-config ~/.ssh/config
fi

if [ ! -d ~/project/scripts/toolbox ]; then
  rsync -rhv --delete environment/unix/scripts/ ~/project/scripts/
fi

rm -rf ~/vm2.sh
