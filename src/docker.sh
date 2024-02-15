#!/usr/bin/env bash

set -e

provision_setup_docker() {
  cat >>~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-yaml')
EOF

  cat >>~/.shell_sources <<"EOF"
source_if_exists ~/.docker-completion.sh
EOF

  cat >>~/.shell_aliases <<"EOF"
alias DockerAttachLastContainer='docker start  `docker ps -q -l`; docker attach `docker ps -q -l`'
alias DockerCleanAll='docker stop $(docker ps -aq); docker rm $(docker ps -aq); docker system prune -fa'
alias DockerCleanContainers='docker stop $(docker ps -aq); docker rm $(docker ps -aq)'
alias DockerInfo='docker info | less -S'
alias DockerRmAll='docker rm $(docker ps -aq)'

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

DockerHistory() { docker history --no-trunc $1 | less -S; }

DockerTags() {
   NAME=$1
   ORG=${2:-library}
   wget -q -O - \
    "https://hub.docker.com/v2/namespaces/$ORG/repositories/$NAME/tags?page_size=100" \
        | grep -o '"name": *"[^"]*' \
        | grep -o '[^"]*$'
}

alias DockerSearch='docker search'

# DockerContainerPortainer 9123
DockerContainerPortainer() { docker run --rm -d -p $1:9000 --name portainer \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/misc/portainer_data:/data \
  portainer/portainer-ce:latest; }

# Only AMD for now
alias DockerDive='docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest'

# Common applications examples using docker
alias DockerRunApache='docker run --rm --name apache -p 127.0.0.1:9000:80 -v $(pwd):/usr/local/apache2/htdocs httpd'
# AWSDocker -v "$(pwd):/var/foo"
DockerRunAWS() {
  docker run --rm -it --entrypoint '' \
    -v "$HOME"/.aws/credentials.json:/root/.aws/credentials.json \
    $@ \
    amazon/aws-cli /bin/bash
}
alias DockerRunPostgres='docker run --rm --name pg -p 127.0.0.1:1234:5432 -e POSTGRES_PASSWORD=secret -v $HOME/misc/pg:/var/lib/postgresql/data postgres'

alias DockerKillAll='docker kill $(docker ps -q)'

if type minikube >/dev/null 2>&1; then
  alias MinikubeDashboard='minikube dashboard --port=9000 --url=true'
fi
EOF

  if [ -f "$PROVISION_CONFIG"/docker-skip ]; then
    return
  fi

  if [ "$IS_MAC" == "1" ]; then
    return
  fi

  if ! type docker >/dev/null 2>&1; then
    curl -fsSL https://get.docker.com | sh
    sudo usermod -a -G docker igncp
  fi

  echo 'export PATH=$PATH:/usr/local/lib/docker/bin' >>~/.shellrc

  mkdir -p ~/.docker/cli-plugins

  if [ "$IS_LINUX" == "1" ] && [ "$IS_NIXOS" != "1" ]; then
    install_system_package_os 'docker-compose'
    if [ -z "$(docker info | grep buildx || true)" ]; then
      if [ "$IS_DEBIAN" == "1" ]; then
        install_system_package_os 'docker-buildx-plugin'
      else
        install_system_package_os 'docker-buildx'
      fi
    fi
  fi

  cat >>~/.shellrc <<"EOF"
export DOCKER_BUILDKIT=1
EOF
  cat >>~/.shell_aliases <<"EOF"
alias DockerBuildXInstall='docker run --privileged --rm tonistiigi/binfmt --install all'
# Just run once, for allowing the `--push` flag on `docker buildx build`
alias DockerBuildXDriver='docker buildx create --use --name build --node build --driver-opt network=host'
EOF
}
