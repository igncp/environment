#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR"

mkdir -p ./config

sudo docker run \
  --rm \
  -it \
  --net host \
  --rm \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME"/.Xauthority:/home/ubuntu/.Xauthority \
  -v $PWD:/app \
  -e DISPLAY=$DISPLAY \
  -w /app \
  gui-cursor \
  bash
