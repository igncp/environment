#!/usr/bin/env bash

set -e

mkdir -p content

sudo docker run \
  --rm \
  -v "$(pwd):/project" \
  -v "$(pwd)/results:/home/ubuntu/results" \
  -v "$(pwd)/examples:/home/ubuntu/examples" \
  -v "$(pwd)/content:/home/ubuntu/content" \
  -v "$(pwd)/scripts:/home/ubuntu/scripts" \
  -it \
  --name diagrams \
  diagrams \
  /bin/bash
