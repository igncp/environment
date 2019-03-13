#!/usr/bin/env bash

set -e

if test -n "$(sudo docker container ls -a | grep mysql-workbench)"; then
  sudo docker stop mysql-workbench
  sudo docker start mysql-workbench
  exit 0
fi

sudo docker run \
  -d \
  -v "$(pwd):/project:ro" \
  -v "$HOME/.Xauthority:/home/ubuntu/.Xauthority:rw" \
  --env="DISPLAY" \
  --net host \
  -it \
  --name mysql-workbench \
  mysql-workbench
