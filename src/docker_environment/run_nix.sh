#!/usr/bin/env bash

set -e

DOCKER_SOCKET=/var/run/docker.sock

if [ -S $HOME/.docker/run/docker.sock ]; then
  DOCKER_SOCKET=$HOME/.docker/run/docker.sock
fi

docker run \
  --rm \
  -it \
  --name nix_env \
  -e TZ=Asia/Hong_Kong \
  -v $PWD:/data \
  -v $HOME/development/environment:/environment \
  -v nix_env:/nix \
  -v nix_env_home:/home/igncp \
  -v nix_env_config:/environment/project/.config \
  -v $DOCKER_SOCKET:/var/run/docker.sock \
  nixos/nix \
  bash /environment/src/docker_environment/entrypoint_nix.sh
