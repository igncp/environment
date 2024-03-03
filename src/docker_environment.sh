#!/usr/bin/env bash

set -e

SCRIPT_PATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

cd "$SCRIPT_PATH/.."

docker build --build-arg HOST_UID=$(id -u) \
  --progress=plain \
  -t environment .

docker run --rm -it \
  -v "$(pwd):/app" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --privileged \
  -p 2200:2200 \
  environment \
  sh -c '. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && zsh ; exit'
