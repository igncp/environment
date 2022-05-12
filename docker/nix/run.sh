#!/bin/bash

set -e

docker run \
  -it \
  --rm \
  $@ \
  nixos/nix \
  /bin/bash
