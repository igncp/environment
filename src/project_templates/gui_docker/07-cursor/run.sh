#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR"

mkdir -p ./config

podman run \
  --rm \
  -it \
  --net host \
  --env WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  --volume $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY \
  --env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  --user $(id -u):$(id -g) \
  --security-opt label=disable \
  --userns=keep-id \
  -w /home/ubuntu \
  gui-cursor \
  bash
