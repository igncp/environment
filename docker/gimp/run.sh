#!/usr/bin/env bash

set -e

CONTAINER_NAME=gimp

(sudo docker container stop $CONTAINER_NAME || true)

(sudo docker container rm $CONTAINER_NAME || true)

sudo docker run \
  --rm \
  --net=host \
  --env="DISPLAY" \
  --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
  --entrypoint=/bin/bash \
  -it \
  --name $CONTAINER_NAME \
  $CONTAINER_NAME
