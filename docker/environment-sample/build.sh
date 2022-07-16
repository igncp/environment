#!/usr/bin/env bash

set -e

docker rmi environment-foo || true

cat > /tmp/Dockerfile.env <<"EOF"
FROM archlinux

RUN useradd igncp -u 1000 -s /bin/bash
EOF

docker build \
  -t environment-foo \
  -f /tmp/Dockerfile.env \
  .
