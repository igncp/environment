#!/usr/bin/env bash

set -e

rm -rf ~/project/scripts/ts-morph

rsync -rhv --delete \
  ~/.ts-morph/ ~/project/scripts/ts-morph/ \
  --exclude node_modules \
  --exclude 'build'
