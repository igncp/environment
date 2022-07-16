#!/usr/bin/env bash

set -e

docker run \
  -v /host:$(pwd) \
  --rm -it \
  --user 1000:1000 \
  --workdir /home/igncp \
  environment-foo \
  /bin/bash
