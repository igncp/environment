#!/usr/bin/env bash

set -e

SCRIPT_PATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"
IS_MACOS=$(uname -s | grep -i Darwin || true)

# 可能的選擇
# - 'volumes': 使用目錄磁碟區在主機和容器之間共用資料。容器停止後即可取出
# - 'inner': 不使用卷，容器狀態不會被移除，並且每次都會重新啟動。
RUNNING_MODE="volumes"

if [ -n "$IS_MACOS" ]; then
  RUNNING_MODE="inner"
fi

cd "$SCRIPT_PATH/.."

mkdir -p ~/misc/docker_environment/project
mkdir -p ~/.1password

if [ $RUNNING_MODE = "volumes" ]; then
  if [ ! -d ~/misc/docker_environment/usr ]; then
    docker run --rm \
      -v $HOME/misc/docker_environment:/mnt \
      debian:bookworm \
      bash -c "cp -r /etc /mnt && cp -r /var /mnt && cp -r /usr /mnt && cp -r /opt /mnt"
  fi
else
  if [ -n "$(docker ps -a | grep environment || true)" ]; then
    docker start -ia environment

    return 0
  fi
fi

echo "run.sh START_SCRIPT: $START_SCRIPT"

VOLUMES_OPTS=()

if [ $RUNNING_MODE = "volumes" ]; then
  VOLUMES_OPTS+=(
    -v $HOME/misc/docker_environment/nix:/nix
    -v $HOME/misc/docker_environment/etc:/etc
    -v $HOME/misc/docker_environment/var:/var
    -v $HOME/misc/docker_environment/usr:/usr
    -v $HOME/misc/docker_environment/root:/root
    -v $HOME/misc/docker_environment/home:/home
    -v $HOME/misc/docker_environment/opt:/opt
  )
fi

docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  "${VOLUMES_OPTS[@]}" \
  -v $HOME/development/environment:/home/igncp/development/environment \
  -v $HOME/misc/docker_environment/project:/home/igncp/development/environment/project \
  -v $HOME/.ssh:/home/igncp/.ssh \
  -v $HOME/.1password:/home/igncp/.1password \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME"/.Xauthority:/home/igncp/.Xauthority \
  -v $HOME:/host_home \
  --privileged \
  --net host \
  -e DISPLAY=$DISPLAY \
  -e HOST_UID=$(id -u) \
  -e HOST_DOCKER_GID="$(getent group docker | cut -d: -f3)" \
  -e START_SCRIPT="$START_SCRIPT" \
  --name environment \
  debian:bookworm \
  bash /home/igncp/development/environment/src/docker_environment/entrypoint.sh
