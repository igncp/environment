#!/usr/bin/env bash

set -euo pipefail

provision_setup_containers() {
  if type zsh >/dev/null 2>&1; then
    if type docker >/dev/null 2>&1; then
      if [ ! -f "$HOME/.oh-my-zsh/completions/_docker" ]; then
        mkdir -p "$HOME/.oh-my-zsh/completions"
        docker completion zsh >"$HOME/.oh-my-zsh/completions/_docker"
      fi
    fi
  fi

  cat >>~/.shell_aliases <<"EOF"
_CONTAINER_PRUNE_ALIAS='docker system prune -fa ; docker volume prune -fa ; docker network prune -f'
if type crictl >/dev/null 2>&1; then
  _CONTAINER_PRUNE_ALIAS="$_CONTAINER_PRUNE_ALIAS ; sudo crictl rmi --prune"
fi
alias ContainerPruneAll="$_CONTAINER_PRUNE_ALIAS"

alias DockerAttachLastContainer='docker start  `docker ps -q -l`; docker attach `docker ps -q -l`'
alias DockerCleanAll='docker stop $(docker ps -aq); docker rm $(docker ps -aq); docker system prune -fa'
alias DockerCleanContainers='docker stop $(docker ps -aq); docker rm $(docker ps -aq)'
alias DockerInfo='docker info | less -S'
alias DockerRmAll='docker rm $(docker ps -aq)'

alias ContainerdImages='sudo crictl images'

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
alias DockerSystemSpace='docker system df --verbose'

DockerHistory() { docker history --no-trunc $1 | less -S; }

DockerHadolint() {
  nix-shell -p hadolint --run "hadolint ${1:-./Dockerfile}"
}

DockerLazy() {
  # https://github.com/jesseduffield/lazydocker
  nix-shell -p lazydocker --run lazydocker
}

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

alias DockerKillAll='docker kill $(docker ps -q)'

if type minikube >/dev/null 2>&1; then
  alias MinikubeDashboard='minikube dashboard --port=9000 --url=true'
fi
EOF

  if [ ! -f "$PROVISION_CONFIG"/docker ] && [ ! -f "$PROVISION_CONFIG"/podman ]; then
    return
  fi

  if [ "$PROVISION_CONFIG" == "docker" ] && [ "$IS_MAC" != "1" ]; then
    if [ ! -S /var/run/docker.sock ]; then
      curl -fsSL https://get.docker.com | sh
      sudo usermod -a -G docker $USER
    fi

    echo 'export PATH=$PATH:/usr/local/lib/docker/bin' >>~/.shellrc

    mkdir -p ~/.docker/cli-plugins

    cat >>~/.shellrc <<"EOF"
export DOCKER_BUILDKIT=1
EOF
    cat >>~/.shell_aliases <<"EOF"
DockerBuildXInstallDriver() {
  docker buildx rm mybuilder || true
  docker buildx create --name mybuilder --use --bootstrap
  docker run --privileged --rm tonistiigi/binfmt --install all
  docker buildx ls
}
# Just run once, for allowing the `--push` flag on `docker buildx build`
alias DockerBuildXDriver='docker buildx create --use --name build --node build --driver-opt network=host'
EOF
  fi

  # https://docs.podman.io/en/stable/Commands.html
  if type podman >/dev/null 2>&1; then
    mkdir -p "$HOME/.config/containers"
    mkdir -p "$HOME/.podman"

    if [ ! -f "$HOME/.config/containers/policy.json" ]; then
      echo 'unqualified-search-registries = ["docker.io"]' >"$HOME/.config/containers/registries.conf"

      curl -o "$HOME/.config/containers/policy.json" \
        https://raw.githubusercontent.com/containers/skopeo/main/default-policy.json
    fi
    cat >$HOME/.config/containers/storage.conf <<EOF
[storage]
driver = "overlay"
graphroot = "$HOME/.podman/graph"
runroot = "$HOME/.podman/run"

[storage.options]
size = ""
EOF
    cat >$HOME/.config/containers/containers.conf <<EOF
[containers]
volume_path = "$HOME/.podman/volumes"
[engine]
cgroup_manager = "cgroupfs"
EOF
  fi
}
