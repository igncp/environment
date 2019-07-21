#!/usr/bin/env bash

set -e

sudo mkdir -p \
  ~/.docker/gitlab/config \
  ~/.docker/gitlab/logs \
  ~/.docker/gitlab/data

sudo docker run \
  --publish 5080:80 \
  --volume ~/.docker/gitlab/config:/etc/gitlab:Z \
  --volume ~/.docker/gitlab/logs:/var/log/gitlab:Z \
  --volume ~/.docker/gitlab/data:/var/opt/gitlab:Z \
  --name gitlab-ce \
  --rm \
  gitlab/gitlab-ce
