#!/usr/bin/env bash

set -e

docker volume create portainer_data

docker run \
  -d \
  --rm \
  -p 9050:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --name portainer \
  portainer/portainer
