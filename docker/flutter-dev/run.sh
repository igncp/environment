#!/usr/bin/env bash

set -e

if test -n "$(sudo docker container ls -a | grep flutter-dev)"; then
  sudo docker stop flutter-dev
  sudo docker start flutter-dev
  sudo docker exec -it flutter-dev /bin/bash
  exit 0
fi

sudo docker run \
  -v "$(pwd):/project" \
  -v "$HOME/.Xauthority:/home/ubuntu/.Xauthority:rw" \
  --env="DISPLAY" \
  --net host \
  -it \
  --name flutter-dev \
  flutter-dev \
  /bin/bash
