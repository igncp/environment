#!/usr/bin/env bash

set -euo pipefail

docker run --rm -it \
  --net="host" \
  --pid="host" \
  --name=node-exporter \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter:latest \
  --path.rootfs=/host
