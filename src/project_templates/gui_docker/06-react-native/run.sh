#!/usr/bin/env bash

set -e

mkdir -p Android
mkdir -p .gradle
mkdir -p AndroidStudioProjects
mkdir -p app
mkdir -p .android
mkdir -p studio_config
touch .bash_history

docker run \
  --rm \
  -it \
  --net host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME"/.Xauthority:/home/igncp/.Xauthority \
  -v $PWD/Android:/home/igncp/Android \
  -v $PWD/AndroidStudioProjects:/home/igncp/AndroidStudioProjects \
  -v $PWD/.gradle:/home/igncp/.gradle \
  -v $PWD/.android:/home/igncp/.android \
  -v $PWD/.bash_history:/home/igncp/.bash_history \
  -v $PWD/studio_config:/home/igncp/.config/Google \
  -v $PWD/app:/app \
  -w /app \
  -e DISPLAY=$DISPLAY \
  --privileged \
  gui-test-react-native \
  bash -c "SHELL=/usr/bin/bash tmux"
