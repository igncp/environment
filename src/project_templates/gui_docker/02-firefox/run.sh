#!/usr/bin/env bash

set -e

docker run \
  --rm \
  -it \
  --net host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME"/.Xauthority:/home/igncp/.Xauthority \
  -e DISPLAY=$DISPLAY \
  gui-test-firefox
