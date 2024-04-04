#!/usr/bin/env bash

set -e

docker run \
  --net host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME"/.Xauthority:/home/igncp/.Xauthority \
  -e DISPLAY=$DISPLAY \
  gui-test-ubuntu-2004
