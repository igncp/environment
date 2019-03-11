#!/usr/bin/env bash

set -e

V_PATH=~/.docker/verdaccio

sudo mkdir -p \
  $V_PATH/storage \
  $V_PATH/plugins

sudo chown -R 100:101 $V_PATH

sudo docker run \
  -it \
  --rm \
  --name verdaccio \
  -p 4873:4873 \
  -v $V_PATH/storage:/verdaccio/storage \
  -v $V_PATH/plugins:/verdaccio/plugins \
  verdaccio/verdaccio
