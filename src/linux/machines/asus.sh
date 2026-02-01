#!/usr/bin/env bash

set -euo pipefail

setup_machines_asus() {
  if [ "$IS_ASUS" != "1" ]; then
    return
  fi

  cat >>~/.shell_aliases <<'EOF'
AsusDecreaseBrightness() {
  sudo brightnessctl s 10%-
}
AsusIncreaseBrightness() {
  sudo brightnessctl s 10%+
}
AsusBrightnessLowest() {
  sudo brightnessctl s 1
}
alias Battery='echo "$(cat /sys/class/power_supply/BAT0/capacity)% $(cat /sys/class/power_supply/BAT0/status)"'
EOF
}
