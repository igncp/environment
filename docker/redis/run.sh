#!/usr/bin/env bash

# Instructions:
# https://hub.docker.com/_/redis/

set -e

sudo docker run \
  --rm \
  --name redis \
  redis \
  redis-server \
  --appendonly yes
