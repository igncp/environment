#!/usr/bin/env bash

# Instructions
# - Download the SDK from https://flutter.dev/docs/get-started/install/linux
# - Place it in this directory as flutter-sdk.tar.xz

set -e

sudo docker build \
  -t flutter-dev \
  .
