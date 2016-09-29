#!/usr/bin/env bash

NODE_VERSION=6.3.0

if [ ! -f ~/node-installation-finished ]; then
  echo "setup node with nodenv"
  sudo add-apt-repository -y ppa:chris-lea/node.js && \
    sudo apt-get update && \
    sudo curl -O -L https://npmjs.org/install.sh | sh && \
    if [ ! -d ~/.nodenv ]; then git clone https://github.com/nodenv/nodenv.git ~/.nodenv && cd ~/.nodenv && src/configure && make -C src; fi && \
    export PATH=$PATH:/home/$USER/.nodenv/bin && \
    eval "$(nodenv init -)" && \
    if [ ! -d ~/.nodenv/plugins/node-build ]; then git clone https://github.com/nodenv/node-build.git $(nodenv root)/plugins/node-build; fi && \
    if [ ! -d .nodenv/versions/$NODE_VERSION ]; then nodenv install $NODE_VERSION; fi && \
    nodenv global $NODE_VERSION && \
    touch ~/node-installation-finished
fi

GLOBAL_NPM_MODULES=(http-server diff-so-fancy eslint babel-eslint)

for MODULE_NAME in "${GLOBAL_NPM_MODULES[@]}"; do
  if [ ! -d ~/.nodenv/versions/$NODE_VERSION/lib/node_modules/$MODULE_NAME ]; then
    echo "doing: npm i -g $MODULE_NAME"
    npm i -g $MODULE_NAME
  fi
done
