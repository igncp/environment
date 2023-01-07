# docker START

install_system_package docker

# TODO: option to set up https://github.com/chaifeng/ufw-docker
install_system_package docker-compose

if [ ! -f ~/.check-files/docker ]; then
  sudo usermod -a -G docker "$USER" # may need reboot
  sudo systemctl enable --now docker

  if [ -n "$ARM_ARCH" ]; then REGCTL_ARCH=arm64 ; else REGCTL_ARCH=amd64 ; fi
  if [ "$PROVISION_OS" = "MAC" ]; then REGCTL_OS=darwin ; else REGCTL_OS=linux ; fi

  curl -L "https://github.com/regclient/regclient/releases/latest/download/regctl-$REGCTL_OS-$REGCTL_ARCH" \
    > /tmp/regctl
  sudo mv /tmp/regctl /usr/bin/regctl
  sudo chmod +x /usr/bin/regctl

  touch ~/.check-files/docker
fi

echo 'export PATH=$PATH:/usr/local/lib/docker/bin' >> ~/.shellrc
echo 'source_if_exists ~/.docker-completion.sh' >> ~/.shell_sources

mkdir -p ~/.docker/cli-plugins

if [ ! -f ~/.docker/cli-plugins/docker-compose ]; then
  if [ -n "$ARM_ARCH" ]; then COMPOSE_ARCH=aarch64 ; else COMPOSE_ARCH=x86_64 ; fi
  if [ "$PROVISION_OS" = "MAC" ]; then COMPOSE_OS=darwin ; else COMPOSE_OS=linux ; fi
  wget "https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-$COMPOSE_OS-$COMPOSE_ARCH" \
    -O ~/.docker/cli-plugins/docker-compose
  sudo chmod +x ~/.docker/cli-plugins/docker-compose
fi

cat >> ~/.shell_aliases <<"EOF"
alias DockerAttachLastContainer='docker start  `docker ps -q -l`; docker attach `docker ps -q -l`'
alias DockerCleanAll='docker stop $(docker ps -aq); docker rm $(docker ps -aq); docker rmi $(docker images -q)'
alias DockerCleanContainers='docker stop $(docker ps -aq); docker rm $(docker ps -aq)'
alias DockerInfo='docker info | less -S'

DComposeConvertJson(){ docker compose "$@" convert --format json; } # DComposeConvertJson -f ./foo.yml
DComposeTop(){ docker compose "$@" top | less -S; } # DComposeTop -f ./foo.yml
DComposeLogs(){ docker compose "$@" logs -f; } # DComposeLogs -f ./foo.yml
DComposeLogsNew(){ docker compose "$@" logs -f --since 0s; } # DComposeLogsNew -f ./foo.yml
DComposeFullRestart(){
  docker compose "${@: 2}" stop "$1"
  docker compose "${@: 2}" rm "$1" --force
  docker compose "${@: 2}" up "$1" -d --build
}

alias DComposeConfig='docker compose config' # Prints the config after pre-processing
alias DockerCommit='docker commit -m'
alias DockerPruneAll='docker system prune --volumes --all'
alias DockerSystemSpace='docker system df --verbose'

DockerBashExec() { docker exec -it $1 /bin/bash; }
DockerBashRun() { docker run -it $1 /bin/bash; }
DockerHistory() { docker history --no-trunc $1 | less -S; }

# DockerContainerPortainer 9123
DockerContainerPortainer() { docker run --rm -d -p $1:9000 --name portainer \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/misc/portainer_data:/data \
  portainer/portainer-ce:latest; }

# Only AMD for now
alias DockerDive='docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest'
EOF

if [ -f ~/project/.config/docker-buildx ]; then
  if [ ! -f ~/.docker/cli-plugins/docker-buildx ]; then
    if [ -n "$ARM_ARCH" ]; then BUILDX_ARCH=arm64 ; else BUILDX_ARCH=amd64 ; fi
    if [ "$PROVISION_OS" = "MAC" ]; then BUILDX_OS=darwin ; else BUILDX_OS=linux ; fi
    wget "https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.$BUILDX_OS-$BUILDX_ARCH" \
      -O ~/.docker/cli-plugins/docker-buildx
    sudo chmod +x ~/.docker/cli-plugins/docker-buildx
  fi

  if [ ! -f ~/.check-files/docker-buildx ]; then
    docker run --privileged --rm tonistiigi/binfmt --install all
    touch ~/.check-files/docker-buildx
  fi

  echo 'export DOCKER_BUILDKIT=1' >> ~/.shellrc

  cat >> ~/.shell_aliases <<"EOF"
# Just run once, for allowing the `--push` flag on `docker buildx build`
alias DockerBuildXDriver='docker buildx create --use --name build --node build --driver-opt network=host'
EOF
fi

cat >> ~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-yaml')
EOF

# docker END
