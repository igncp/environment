#!/usr/bin/env bash

set -e

sudo docker run \
  --rm \
  -v "$(pwd):/project:ro" \
  -it \
  --name nodenv \
  nodenv \
  /bin/bash
