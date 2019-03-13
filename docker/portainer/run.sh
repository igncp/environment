#!/usr/bin/env bash

set -e

sudo docker volume create portainer_data

if test -n "$(sudo docker container ls -a | grep portainer)"; then
  (sudo docker stop portainer || true)
  sudo docker start portainer
  exit 0
fi

sudo docker run \
  -d \
  --rm \
  -p 9050:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --name portainer \
  portainer/portainer
