#!/usr/bin/env bash

set -e

if test -n "$(sudo docker container ls -a | grep android-studio)"; then
  sudo docker stop android-studio
  sudo docker start android-studio
  sudo docker exec -it android-studio /bin/bash
  exit 0
fi

sudo docker run \
  -v "$(pwd):/project:ro" \
  -v "$HOME/.Xauthority:/home/ubuntu/.Xauthority:rw" \
  --env="DISPLAY" \
  --net host \
  -it \
  --name android-studio \
  android-studio \
  /bin/bash
