#!/usr/bin/env bash

set -e

. src/bash/env.sh
. src/bash/nix.sh
. src/bash/zsh.sh
. src/bash/general.sh

. src/bash/android.sh
. src/bash/dart.sh
. src/bash/docker.sh
. src/bash/go.sh
. src/bash/hashi.sh

provision_setup_with_bash() {
  provision_setup_env
  provision_setup_nix
  provision_setup_zsh
  provision_setup_general

  provision_setup_android
  provision_setup_dart
  provision_setup_docker
  provision_setup_go
  provision_setup_hashi
}
