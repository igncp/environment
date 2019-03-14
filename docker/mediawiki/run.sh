#!/usr/bin/env bash

set -e

if test -n "$(sudo docker container ls -a | grep mediawiki)"; then
  sudo docker-compose down
  exit 0
fi

sudo docker-compose up
