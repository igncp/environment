#!/usr/bin/env bash

set -e

. src/bash/entry.sh

provision_main() {
  provision_setup_with_bash

  echo "Bash provision finished successfully"
}

provision_main
