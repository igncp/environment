#!/usr/bin/env bash

set -e

sudo docker run \
  --rm \
  -p 8888:8888 \
  jupyter/datascience-notebook:latest
