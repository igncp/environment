# docker START

install_system_package docker
install_system_package docker-compose

if [ ! -f ~/.check-files/docker ]; then
  sudo usermod -a -G docker "$USER" # may need reboot
  sudo systemctl enable --now docker

  touch ~/.check-files/docker
fi

echo 'export PATH=$PATH:/usr/local/lib/docker/bin' >> ~/.shellrc
echo 'source_if_exists ~/.docker-completion.sh' >> ~/.shell_sources

cat >> ~/.shell_aliases <<"EOF"
alias DockerAttachLastContainer='docker start  `docker ps -q -l`; docker attach `docker ps -q -l`'
alias DockerCleanAll='docker stop $(docker ps -aq); docker rm $(docker ps -aq); docker rmi $(docker images -q)'
alias DockerCleanContainers='docker stop $(docker ps -aq); docker rm $(docker ps -aq)'

DComposeConvertJson(){ docker compose "$@" convert --format json; } # DComposeConvertJson -f ./foo.yml
DComposeTop(){ docker compose "$@" top | less -S; } # DComposeTop -f ./foo.yml
DComposeLogs(){ docker compose "$@" logs -f; } # DComposeLogs -f ./foo.yml
DComposeLogsNew(){ docker compose "$@" logs -f --since 0s; } # DComposeLogsNew -f ./foo.yml
DComposeFullRestart(){
  docker compose "${@: 2}" stop "$1"
  docker compose "${@: 2}" rm "$1" --force
  docker compose "${@: 2}" up "$1" -d --build
}

alias DockerSystemSpace='docker system df --verbose'
alias DockerPruneAll='docker system prune --volumes --all'

DockerBashRun() { docker run -it $1 /bin/bash; }
DockerBashExec() { docker exec -it $1 /bin/bash; }
EOF

# docker END
