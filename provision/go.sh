#!/usr/bin/env bash

if ! type go > /dev/null 2>&1 ; then
  echo "installing go"
  cd ~
  curl -O https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz && \
  sudo tar -zxf go1.5.3.linux-amd64.tar.gz && \
  sudo chown -R $USER:$USER go && \
  mv go ~/.go && \
  rm go1.5.3.linux-amd64.tar.gz && \
  sudo wget https://raw.github.com/kura/go-bash-completion/master/etc/bash_completion.d/go -O /etc/bash_completion.d/go
  mkdir -p ~/.go-workspace
  . ~/.bashrc

  go get -u github.com/golang/lint/golint
fi