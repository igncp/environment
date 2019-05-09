#!/usr/bin/env bash

set -e

if test -n "$(sudo docker container ls -a | grep java)"; then
  sudo docker stop java
  sudo docker start java
  sudo docker exec -it java /bin/bash
  exit 0
fi

sudo docker run \
  -v "$(pwd):/project:ro" \
  -v "$HOME/.Xauthority:/home/ubuntu/.Xauthority:rw" \
  --env="DISPLAY" \
  --net host \
  -it \
  --name java \
  java \
  /bin/bash
