#!/usr/bin/env bash

set -e

if [ ! -f ~/.check-files/first-run ]; then
  echo "This is the first run"
  set -x
fi

. src/entry.sh

provision_main() {
  provision_setup_with_bash
  touch ~/.check-files/first-run

  echo "The provision finished successfully"
}

provision_main
