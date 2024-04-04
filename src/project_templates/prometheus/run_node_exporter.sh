#!/usr/bin/env bash

set -e

docker run --rm -it \
  --net="host" \
  --pid="host" \
  --name=node-exporter \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter:latest \
  --path.rootfs=/host
