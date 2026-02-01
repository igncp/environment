#!/usr/bin/env bash

set -euo pipefail

. src/linux/machines/surface.sh
. src/linux/machines/asus.sh

provision_setup_linux_machines() {
  setup_machines_surface
  setup_machines_asus
}
