#!/usr/bin/env bash

set -e

echo "listening on port 5000"

if test -n "$(sudo docker container ls -a | grep mindmaps)"; then
  sudo docker stop mindmaps
  sudo docker start mindmaps
  exit 0
fi

sudo docker run \
  -d \
  -p 5000:5000 \
  -it \
  --name mindmaps \
  mindmaps
