#!/usr/bin/env bash

# You can download the latest Ubuntu version from:
# https://developer.tizen.org/development/tizen-studio/download And place it in
# this directory (bin files will be ignored) Only the normal IDE is supported
# (not RT, which requires Docker CE inside the container)

set -e

if test -n "$(sudo docker container ls -a | grep tizen-studio)"; then
  docker stop tizen-studio
  docker start tizen-studio
  docker exec -it tizen-studio /bin/bash
  exit 0
fi

docker run \
  -v "$(pwd):/project:ro" \
  -v "/tmp/.X11-unix:/tmp/.X11-unix" \
  --net=host \
  --env="DISPLAY" \
  -it \
  --name tizen-studio \
  tizen-studio \
  /bin/bash
