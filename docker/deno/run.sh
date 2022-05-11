#!/bin/bash

# https://github.com/denoland/deno_docker

set -e

docker run \
  --interactive \
  --tty \
  --rm \
  --volume $PWD:/app \
  --volume $HOME/.deno:/deno-dir \
  --workdir /app \
  denoland/deno:latest \
  "$@"
