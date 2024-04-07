#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR"

mkdir -p Android
mkdir -p .gradle
mkdir -p AndroidStudioProjects

docker run \
  --rm \
  -it \
  --net host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME"/.Xauthority:/home/igncp/.Xauthority \
  -v $PWD/Android:/home/igncp/Android \
  -v $PWD/AndroidStudioProjects:/home/igncp/AndroidStudioProjects \
  -v $PWD/.gradle:/home/igncp/.gradle \
  -v $PWD/..:/app \
  -w /app \
  -e DISPLAY=$DISPLAY \
  --privileged \
  gui-test-android-studio \
  bash -c "bash"
