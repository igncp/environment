#!/bin/bash

set -e

docker run \
  --rm \
  --env="MYSQL_ROOT_PASSWORD=secret" \
  --publish 3306:3306 \
  -v "$(pwd)":/var/lib/mysql \
  mysql/mysql-server
