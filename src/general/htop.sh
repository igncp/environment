#!/usr/bin/env bash

set -euo pipefail

provision_setup_general_htop() {
  # https://github.com/htop-dev/htop

  # https://www.thegeekstuff.com/2011/09/linux-htop-examples
  # C: configuration, w: see command wrapped
  mkdir -p ~/.config/htop
  cp ~/development/environment/src/config-files/htoprc ~/.config/htop/htoprc

  cat >>~/.shell_aliases <<"EOF"
alias HTopCPU='sudo htop -s PERCENT_CPU -d 6000'
alias HTopMem='sudo htop -s PERCENT_MEM -d 6000'
EOF
}
