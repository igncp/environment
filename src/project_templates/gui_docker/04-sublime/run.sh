#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR"

mkdir -p ./config

# 它呼叫 `subl ./ && bash` 而不僅僅是 `subl`, 否則 docker 容器將被停止

docker run \
  --rm \
  -it \
  --net host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME"/.Xauthority:/home/igncp/.Xauthority \
  -v $PWD/config:/home/igncp/.config/sublime-text-3 \
  -v $PWD/..:/app \
  -w /app \
  -e DISPLAY=$DISPLAY \
  gui-test-sublime \
  bash -c "subl ./ && bash"
