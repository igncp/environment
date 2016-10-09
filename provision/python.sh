#!/usr/bin/env bash

if ! type pip > /dev/null  ; then
  echo "installing python tools"

  sudo apt-get install -y python-pip
fi

GLOBAL_PIP_MODULES=(flake8 plotly)

for MODULE_NAME in "${GLOBAL_PIP_MODULES[@]}"; do
  if [ ! -d /usr/local/lib/python2.7/dist-packages/$MODULE_NAME ]; then
    echo "doing: sudo pip install $MODULE_NAME"
    sudo pip install $MODULE_NAME
  fi
done
