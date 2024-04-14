#!/usr/bin/env bash

set -e

SCRIPT_PATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

cd "$SCRIPT_PATH/.."

mkdir -p ~/misc/docker_environment/project
mkdir -p ~/.1password

if [ ! -d ~/misc/docker_environment/usr ]; then
  docker run --rm \
    -v $HOME/misc/docker_environment:/mnt \
    debian:bookworm \
    bash -c "cp -r /etc /mnt && cp -r /var /mnt && cp -r /usr /mnt && cp -r /opt /mnt"
fi

echo "run.sh START_SCRIPT: $START_SCRIPT"

docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/misc/docker_environment/nix:/nix \
  -v $HOME/misc/docker_environment/etc:/etc \
  -v $HOME/misc/docker_environment/var:/var \
  -v $HOME/misc/docker_environment/usr:/usr \
  -v $HOME/misc/docker_environment/root:/root \
  -v $HOME/misc/docker_environment/home:/home \
  -v $HOME/misc/docker_environment/opt:/opt \
  -v $HOME/development/environment:/home/igncp/development/environment \
  -v $HOME/misc/docker_environment/project:/home/igncp/development/environment/project \
  -v $HOME/.ssh:/home/igncp/.ssh \
  -v $HOME/.1password:/home/igncp/.1password \
  -v $HOME:/host_home \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME"/.Xauthority:/home/igncp/.Xauthority \
  --privileged \
  --net host \
  -e DISPLAY=$DISPLAY \
  -e HOST_UID=$(id -u) \
  -e HOST_DOCKER_GID="$(getent group docker | cut -d: -f3)" \
  -e START_SCRIPT="$START_SCRIPT" \
  --name environment \
  debian:bookworm \
  bash ~/development/environment/src/docker_environment/entrypoint.sh
