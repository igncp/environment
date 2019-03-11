#!/usr/bin/env bash

# Instructions:
# https://hub.docker.com/_/sonarqube
# Credentials: admin / admin

set -e

sudo mkdir -p \
  ~/.docker/sonarqube_6_7_6/conf \
  ~/.docker/sonarqube_6_7_6/data \
  ~/.docker/sonarqube_6_7_6/logs \
  ~/.docker/sonarqube_6_7_6/extensions

# Obtained by using the command: id
sudo chown -R 999:999 ~/.docker/sonarqube_6_7_6

sudo docker run \
  --name sonarqube \
  --rm \
  -p 9000:9000 \
  -v ~/.docker/sonarqube_6_7_6/conf:/opt/sonarqube/conf \
  -v ~/.docker/sonarqube_6_7_6/data:/opt/sonarqube/data \
  -v ~/.docker/sonarqube_6_7_6/logs:/opt/sonarqube/logs \
  -v ~/.docker/sonarqube_6_7_6/extensions:/opt/sonarqube/extensions \
  sonarqube:6.7.6-community
