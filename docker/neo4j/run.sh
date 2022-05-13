#!/bin/bash

set -e

# https://hub.docker.com/_/neo4j

docker run \
  --rm \
  --publish=7474:7474 \
  --publish=7687:7687 \
  --env=NEO4J_AUTH=none \
  --volume=$HOME/neo4j/data:/data \
  neo4j
