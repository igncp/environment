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

cat environment/unix/os/ubuntu/provision/ubuntu-beginning.sh >> ~/project/provision/provision.sh

cat environment/unix/provision/custom.sh >> ~/project/provision/provision.sh

rm -rf ~/vm2.sh
