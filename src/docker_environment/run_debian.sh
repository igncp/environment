#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

cd "$SCRIPT_PATH/.."

if [ -n "$(docker ps -a | grep "\benvironment\b" || true)" ]; then
  docker start environment

  exit 0
fi

RUN_OPTS=()

if [ -f /tmp/.X11-unix ]; then
  RUN_OPTS+=(
    -v /tmp/.X11-unix:/tmp/.X11-unix
  )
fi

if [ -f $HOME/.Xauthority ]; then
  RUN_OPTS+=(
    -v $HOME/.Xauthority:/home/igncp/.Xauthority
  )
fi

if [ -n "$START_SCRIPT" ]; then
  echo "START_SCRIPT: $START_SCRIPT"
fi

docker run -it \
  -d \
  -p 6022:22 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  "${RUN_OPTS[@]}" \
  -v $SCRIPT_PATH/../..:/home/igncp/development/environment \
  -v environment_project:/home/igncp/development/environment/project \
  -e DISPLAY=$DISPLAY \
  -e HOST_UID=$(id -u) \
  -e HOST_DOCKER_GID="$(getent group docker | cut -d: -f3)" \
  -e START_SCRIPT="$START_SCRIPT" \
  --name environment \
  debian:bookworm \
  bash /home/igncp/development/environment/src/docker_environment/entrypoint_debian.sh
