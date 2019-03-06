#!/usr/bin/env bash

set -e

(sudo docker container stop gimp || true)

(sudo docker container rm gimp || true)

(sudo docker rmi gimp || true)
