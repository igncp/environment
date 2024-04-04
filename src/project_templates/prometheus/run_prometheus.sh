#!/usr/bin/env bash

set -e

mkdir -p data

sudo chown -R $USER:65534 data
sudo chmod -R g+w data

docker run --rm -it \
  --net=host \
  -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v $PWD/data:/prometheus \
  --name prometheus \
  prom/prometheus
