#!/usr/bin/env bash

set -e

if [ ! -d ~/environment ]; then
  echo 'Send via rsync the environment directory'
  # From the host:
    # rsync -rhv ./ 192.168.1.X:/home/igncp/environment
    # ssh 192.168.1.X
  exit 1
fi

cd /home/igncp

mkdir -p /home/igncp/project/provision
mkdir -p /home/igncp/project/scripts

if [ -f /home/igncp/project/provision/provision.sh ]; then
  cp /home/igncp/project/provision/provision.sh /home/igncp/project/provision/provision_backup.sh
fi

cp environment/unix/scripts/create_vim_snippets.sh ~/project/scripts

cp environment/unix/provision/top.sh project/provision/provision.sh
cat environment/unix/os/ubuntu/provision/ubuntu-beginning.sh >> project/provision/provision.sh
cat environment/unix/provision/zsh.sh >> project/provision/provision.sh

cat environment/unix/provision/general.sh >> project/provision/provision.sh
cp environment/unix/configuration-files/htoprc project/provision/

cat environment/unix/provision/linux.sh >> project/provision/provision.sh
cat environment/unix/provision/python.sh >> project/provision/provision.sh
cat environment/unix/provision/vim-base.sh >> project/provision/provision.sh
cat environment/unix/provision/vim-extra.sh >> project/provision/provision.sh
cat environment/unix/provision/vim-root.sh >> project/provision/provision.sh
cat environment/unix/provision/js.sh >> project/provision/provision.sh
cat environment/unix/provision/ts.sh >> project/provision/provision.sh
cat environment/unix/provision/custom.sh >> project/provision/provision.sh

if [ ! -f ~/.ssh/config ]; then
  mkdir -p ~/.ssh
  cp environment/unix/config-files/ssh-client-config ~/.ssh/config
fi

if [ ! -d ~/project/scripts/toolbox ]; then
  rsync -rhv --delete environment/unix/scripts/ ~/project/scripts/
fi

rm -rf ~/vm2.sh
