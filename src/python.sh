#!/usr/bin/env bash

set -e

provision_setup_python() {
  if [ "$IS_WINDOWS" = "1" ]; then
    return
  fi

  if [ "$IS_DEBIAN" = "1" ] && [ ! -f ~/.check-files/python3-venv ]; then
    sudo apt install -y python3-venv
    touch ~/.check-files/python3-venv
  fi

  if [ "$IS_PROVISION_UPDATE" = "1" ]; then
    rm -rf ~/.local/poetry ~/.local/bin/poetry
  fi

  if [ ! -d ~/.local/poetry ]; then
    rm -rf ~/.local/bin/poetry
    cd ~/.local
    python3 -m venv "$PWD/poetry"
    "$PWD/poetry/bin/pip" install -U pip setuptools
    "$PWD/poetry/bin/pip" install poetry
    ln -s "$PWD/poetry/bin/poetry" "$PWD/bin/poetry"
  fi
}
