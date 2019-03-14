#!/usr/bin/env bash

set -e

if test -n "$(sudo docker container ls -a | grep jenkins-lts)"; then
  sudo docker stop jenkins-lts
  sudo docker start jenkins-lts
  exit 0
fi

sudo docker run \
  -d \
  -v jenkins_home:/var/jenkins_home \
  -p 8080:8080 \
  -p 50000:50000 \
  --name jenkins-lts \
  jenkins/jenkins:lts
