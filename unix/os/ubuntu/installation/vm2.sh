#!/usr/bin/env bash

set -e

if [ ! -d ~/environment ]; then
  echo 'Send via rsync the environment directory'
  # From the host:
    # rsync -rhv ./ igncp@192.168.1.X:/home/igncp/environment
    # ssh igncp@192.168.1.X
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
cat environment/unix/provision/general.sh >> project/provision/provision.sh
cat environment/unix/provision/linux.sh >> project/provision/provision.sh
cat environment/unix/provision/python.sh >> project/provision/provision.sh
cat environment/unix/provision/vim-base.sh >> project/provision/provision.sh
cat environment/unix/os/ubuntu/provision/ubuntu-end.sh >> project/provision/provision.sh
cat environment/unix/provision/custom.sh >> project/provision/provision.sh

sed -i 's|___SSH___|[VM]|' project/provision/provision.sh

if [ ! -d ~/project/scripts/toolbox ]; then
  rsync -rhv --delete environment/unix/scripts/ ~/project/scripts/
fi

rm -rf ~/vm2.sh
