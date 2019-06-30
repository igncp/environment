#!/usr/bin/env bash

set -e

mv files/entr.tar.gz .

tar -xf entr.tar.gz

(cd erad* \
  && ./configure \
  && make test \
  && sudo make install)

rm -rf erad* entr.tar.gz
