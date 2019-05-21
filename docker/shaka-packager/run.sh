#!/usr/bin/env bash

set -e

# https://github.com/google/shaka-packager/blob/master/docs/source/docker_instructions.md#run-the-container
# https://hub.docker.com/r/google/shaka-packager/tags/

# - `packager --help | less`
# - https://google.github.io/shaka-packager/html/
# - https://google.github.io/shaka-packager/html/tutorials/tutorials.html

V_PATH=/home/igncp/.docker/shaka-packager

sudo mkdir -p $V_PATH

sudo docker run \
  -v $V_PATH:/media \
  -v $(pwd):/project \
  --net=host \
  -it \
  --rm \
  --name shaka-packager \
  google/shaka-packager
