#!/usr/bin/env bash

# You can download the latest Ubuntu version from:
# https://developer.tizen.org/development/tizen-studio/download And place it in
# this directory (bin files will be ignored) Only the normal IDE is supported
# (not RT, which requires Docker CE inside the container).

# The recommendation is to download both the CLI and IDE.

set -e

if test -n "$(sudo docker container ls -a | grep tizen-studio)"; then
  sudo docker stop tizen-studio
  sudo docker start tizen-studio
  sudo docker exec -it tizen-studio /bin/bash
  exit 0
fi

sudo docker run \
  -v "$(pwd):/project:ro" \
  -v "$HOME/.Xauthority:/home/ubuntu/.Xauthority:rw" \
  --net=host \
  --env="DISPLAY" \
  -it \
  --name tizen-studio \
  tizen-studio \
  /bin/bash
