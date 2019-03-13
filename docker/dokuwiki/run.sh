#!/usr/bin/env bash

set -e

echo "listening on port 4000"

if test -n "$(sudo docker container ls -a | grep dokuwiki)"; then
  sudo docker stop mindmaps
  sudo docker start mindmaps
  exit 0
fi

sudo docker run \
  -p 4000:80 \
  -v "$(pwd):/project:ro" \
  -it \
  --name dokuwiki \
  dokuwiki \
  /bin/bash
