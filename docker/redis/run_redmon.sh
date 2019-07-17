#!/usr/bin/env bash

# Client URL: http://localhost:4567

set -e

sudo mkdir -p ~/.docker/redis
mkdir -p /tmp/redmon-redis

cat > /tmp/redmon-redis/compose.yml <<"EOF"
version: '3'
services:
  redis:
    image: "redis"
    volumes:
      - "~/.docker/redis:/data"
  redmon:
    image: "vieux/redmon"
    ports:
      - "4567:4567"
    depends_on:
      - redis
    command: -r redis://redis:6379
EOF

(sudo docker-compose \
  -f /tmp/redmon-redis-compose.yml \
  down || true)

if [ "$1" == "down" ]; then
  exit
fi

sudo docker-compose \
  -f /tmp/redmon-redis-compose.yml \
  up
