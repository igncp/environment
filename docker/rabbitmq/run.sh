#!/usr/bin/env bash

set -e

# https://hub.docker.com/_/rabbitmq/
# Credentials: guest / guest
# http://localhost:15672
# TODO: Even if some data is saved, now queues and messages are lost when container is stopped

V_PATH=/home/igncp/.docker/rabbitmq

sudo mkdir -p $V_PATH

sudo docker run \
  --rm \
  -p 15672:15672 \
  -p 5672:5672 \
  --name rabbitmq \
  -v $V_PATH:/var/lib/rabbitmq \
  rabbitmq:management
