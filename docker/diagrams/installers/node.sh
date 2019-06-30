#!/usr/bin/env bash

set -e

git clone https://github.com/nodenv/nodenv.git ~/.nodenv

cd ~/.nodenv

src/configure
make -C src

eval "$(~/.nodenv/bin/nodenv init -)"

git clone https://github.com/nodenv/node-build.git $(~/.nodenv/bin/nodenv root)/plugins/node-build
git clone https://github.com/nodenv/nodenv-update.git "$(nodenv root)"/plugins/nodenv-update

echo 'eval "$(~/.nodenv/bin/nodenv init -)"' >> /home/ubuntu/.bashrc

nodenv install
